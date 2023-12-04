// SPDX-License-Identifier: MIT

// Author: Lambdalf the White

pragma solidity >=0.8.4 <0.9.0;

import {ERC173} from '@lambdalf-dev/ethereum-contracts/contracts/utils/ERC173.sol';
import {IERC20} from '@openzeppelin/contracts/interfaces/IERC20.sol';

/**
 * @notice A vault contract that can hold specified ERC20 token on behalf of the user
 */
contract TsunamiVault is ERC173 {
  uint256 public constant ACTIVE = 1;
  uint256 public constant INACTIVE = 2;
  uint256 public state = INACTIVE;
  mapping(address token => bool allowed) public whitelistedToken;
  mapping(address token => mapping(address tokenOwner => uint256 balance)) internal _holdings;

  /// @notice Thrown when depositing while `state` is {INACTIVE}.
  error DEPOSIT_INACTIVE();
  /// @notice Thrown when depositing a token that is not supported.
  error TOKEN_NOT_SUPPORTED();
  /// @notice Thrown when withdrawing more tokens than deposited.
  error INSUFFICIENT_BALANCE();

  constructor(address admin_) ERC173(admin_) {}

  /// @notice Deposits a given amount of a given ERC20 token
  ///
  /// @param token_ the ERC20 contract address
  /// @param amount_ the amount of token to deposit
  ///
  /// Requirements:
  ///
  /// - `state` must be {ACTIVE}.
  /// - `token_` must be eligible for vault deposit.
  /// - `token_` must be a valid ERC20 token contract.
  /// - This contract must be allowed to transfer at least `amount_` of the `token_` token on behalf of the user.
  /// - Caller must own at least `amount_` of the `token_` token.
  function deposit(address token_, uint256 amount_) public {
    if (state != ACTIVE) {
      revert DEPOSIT_INACTIVE();
    }
    if (!whitelistedToken[token_]) {
      revert TOKEN_NOT_SUPPORTED();
    }
    _holdings[token_][msg.sender] += amount_;
    IERC20(token_).transferFrom(msg.sender, address(this), amount_);
  }

  /// @notice Withdraws a given amount of a given ERC20 token
  ///
  /// @param token_ the ERC20 contract address
  /// @param amount_ the amount of token to deposit
  ///
  /// Requirements:
  ///
  /// - `state` must be {ACTIVE}.
  /// - Caller must have deposited at least `amount_` of the `token_` token.
  function withdraw(address token_, uint256 amount_) public {
    if (state != ACTIVE) {
      revert DEPOSIT_INACTIVE();
    }
    uint256 balance = _holdings[token_][msg.sender];
    if (amount_ > balance) {
      revert INSUFFICIENT_BALANCE();
    }
    unchecked {
      _holdings[token_][msg.sender] = balance - amount_;
    }
    IERC20(token_).transfer(msg.sender, amount_);
  }

  /// @notice Switch the contract state between active and inactive.
  ///
  /// Requirements:
  ///
  /// - Caller must be the contract owner.
  function switchPause() public onlyOwner {
    state = state == ACTIVE ? INACTIVE : ACTIVE;
  }

  /// @notice Allows or disallows a given token to be held by the vault.
  ///
  /// @param token_ the ERC20 contract address
  /// @param isAllowed_ whether the token is allowed or not
  ///
  /// Requirements:
  ///
  /// - Caller must be the contract owner.
  function whitelistToken(address token_, bool isAllowed_) public onlyOwner {
    whitelistedToken[token_] = isAllowed_;
  }

  /// @notice Retrieve the deposit balance of a given token for a given holder.
  ///
  /// @param token_ the ERC20 contract address
  /// @param tokenOwner_ the token holder
  ///
  /// @return tokenBalance the user's balance
  function userBalance(address token_, address tokenOwner_) public view returns (uint256 tokenBalance) {
    tokenBalance = _holdings[token_][tokenOwner_];
  }
}
