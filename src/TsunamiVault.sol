// SPDX-License-Identifier: MIT

// Author: Lambdalf the White

pragma solidity >=0.8.4 <0.9.0;

import { ERC173 } from "@lambdalf-dev/ethereum-contracts/contracts/utils/ERC173.sol";

/**
* @notice A vault contract that can hold specified ERC20 token on behalf of the user
*/
contract TsunamiVault is ERC173 {
	uint public constant ACTIVE = 1;
	uint public constant INACTIVE = 2;
	uint public state = INACTIVE;
	mapping(address token => bool allowed) public isAllowed;
	mapping(address token => mapping(address tokenOwner => uint256 balance)) public holdings;

	/// @notice Thrown when depositing while `state` is {INACTIVE}.
	error DEPOSIT_INACTIVE();
	/// @notice Thrown when depositing a token that is not supported.
	error TOKEN_NOT_SUPPORTED();
	/// @notice Thrown when withdrawing more tokens than deposited.
	error INSUFFICIENT_BALANCE();
	/// @notice Thrown when allowing a token that does not exist.
	error INVALID_TOKEN();

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
	/// - This contract must be allowed to transfer at least `amount_` of the `token_` token on behalf of the user.
	/// - Caller must own at least `amount_` of the `token_` token.
	function deposit(address token_, uint256 amount_) public {}

	/// @notice Withdraws a given amount of a given ERC20 token
	/// 
	/// @param token_ the ERC20 contract address
	/// @param amount_ the amount of token to deposit
	/// 
	/// Requirements:
	/// 
	/// - Caller must have deposited at least `amount_` of the `token_` token.
	function withdraw(address token_, uint256 amount_) public {}

	/// @notice Switch the contract state between active and inactive.
	/// 
	/// Requirements:
	/// 
	/// - Caller must be the contract owner.
	function switchPause() public onlyOwner {}

	/// @notice Allows or disallows a given token to be held by the vault.
	/// 
	/// @param token_ the ERC20 contract address
	/// @param isAllowed_ whether the token is allowed or not
	/// 
	/// Requirements:
	/// 
	/// - Caller must be the contract owner.
	/// - `token_` must not be the zero address.
	function whitelistToken() public onlyOwner {}
}