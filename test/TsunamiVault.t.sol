// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import { TsunamiVault } from "../src/TsunamiVault.sol";

import { TestHelper } from "./TestHelper.sol";
import { Mock_ERC20 } from "./Mock_ERC20.sol";
import { IERC173 } from "@lambdalf-dev/ethereum-contracts/contracts/interfaces/IERC173.sol";
import { IERC173Events } from "@lambdalf-dev/ethereum-contracts/test/mocks/events/IERC173Events.sol";

contract Deployed is TestHelper, IERC173Events {
	TsunamiVault testContract;
	Mock_ERC20 testCoin;

  function setUp() public virtual override {
    super.setUp();
    testContract = new TsunamiVault(ADMIN.addr);
    testCoin = new Mock_ERC20();
  }
  function _activate() internal {
  	vm.prank(ADMIN.addr);
  	testContract.switchPause();
  }
  function _whitelistToken() internal {
  	vm.prank(ADMIN.addr);
  	testContract.whitelistToken(address(testCoin), true);
  }
  function _aliceApprove() internal {
		vm.prank(ALICE.addr);
		testCoin.approve(address(testContract), type(uint256).max);
  }
  function _bobApprove() internal {
		vm.prank(BOB.addr);
		testCoin.approve(address(testContract), type(uint256).max);
  }
  function _aliceDeposit() internal {
  	_aliceApprove();
  	vm.prank(ALICE.addr);
  	testCoin.mint(ALICE_DEPOSIT);
  	vm.prank(ALICE.addr);
  	testContract.deposit(address(testCoin), ALICE_DEPOSIT);
  }
  function _bobDeposit() internal {
  	_bobApprove();
  	vm.prank(BOB.addr);
  	testCoin.mint(BOB_DEPOSIT);
  	vm.prank(BOB.addr);
  	testContract.deposit(address(testCoin), BOB_DEPOSIT);
  }
}

// **************************************
// *****           PUBLIC           *****
// **************************************
  // ****************
  // * TsunamiVault *
  // ****************
  	contract Unit_deposit is Deployed {
  		function test_revertWhen_stateIsInactive() public {
  			vm.prank(ALICE.addr);
  			vm.expectRevert(TsunamiVault.DEPOSIT_INACTIVE.selector);
  			testContract.deposit(address(testCoin), TARGET_AMOUNT);
  		}
  		function test_revertWhen_tokenIsNotWhitelisted() public{
  			_activate();
  			vm.prank(ALICE.addr);
  			vm.expectRevert(TsunamiVault.TOKEN_NOT_SUPPORTED.selector);
  			testContract.deposit(address(testCoin), TARGET_AMOUNT);
  		}
  		function test_revertWhen_vaultIsNotAllowed() public {
  			_activate();
  			_whitelistToken();
  			vm.prank(ALICE.addr);
  			vm.expectRevert("ERC20: decreased allowance below zero");
  			testContract.deposit(address(testCoin), TARGET_AMOUNT);
  		}
  		function test_revertWhen_insufficientBalance() public {
  			_activate();
  			_whitelistToken();
  			_aliceApprove();
  			vm.prank(ALICE.addr);
  			vm.expectRevert("ERC20: transfer amount exceeds balance");
  			testContract.deposit(address(testCoin), TARGET_AMOUNT);
  		}
  	}
  	contract Fuzz_deposit is Deployed {
  		function test_fuzzDepositAmount(uint256 amount) public {
  			_activate();
  			_whitelistToken();
  			_aliceDeposit();
  			_bobDeposit();
  			vm.prank(ALICE.addr);
  			amount = bound(amount, 0, type(uint256).max - ALICE_DEPOSIT - BOB_DEPOSIT);
  			testCoin.mint(amount);
  			vm.prank(ALICE.addr);
  			testContract.deposit(address(testCoin), amount);
  			assertEq(
  				testCoin.balanceOf(address(testContract)),
  				ALICE_DEPOSIT + BOB_DEPOSIT + amount,
  				"invalid contract balance"
  			);
  			assertEq(
  				testContract.userBalance(address(testCoin), ALICE.addr),
  				ALICE_DEPOSIT + amount,
  				"invalid alice deposit recorded"
  			);
  			assertEq(
  				testCoin.balanceOf(address(testContract)),
  				testContract.userBalance(address(testCoin), ALICE.addr) + testContract.userBalance(address(testCoin), BOB.addr),
  				"invalid deposit sum"
  			);
  		}
  	}
  	contract Unit_withdraw is Deployed {
  		function test_revertWhen_insufficientdeposit() public {
  			vm.prank(ALICE.addr);
  			vm.expectRevert(TsunamiVault.INSUFFICIENT_BALANCE.selector);
  			testContract.withdraw(address(testCoin), TARGET_AMOUNT);
  		}
  	}
  	contract Fuzz_withdraw is Deployed {
  		function test_fuzzWithdrawAmount(uint256 amount) public {
  			_activate();
  			_whitelistToken();
  			_aliceDeposit();
  			_bobDeposit();
  			vm.prank(ALICE.addr);
  			amount = bound(amount, 0, ALICE_DEPOSIT);
  			testContract.withdraw(address(testCoin), amount);
  			assertEq(
  				testCoin.balanceOf(address(testContract)),
  				ALICE_DEPOSIT + BOB_DEPOSIT - amount,
  				"invalid contract balance"
  			);
  			assertEq(
  				testContract.userBalance(address(testCoin), ALICE.addr),
  				ALICE_DEPOSIT - amount,
  				"invalid alice deposit recorded"
  			);
  			assertEq(
  				testCoin.balanceOf(address(testContract)),
  				testContract.userBalance(address(testCoin), ALICE.addr) + testContract.userBalance(address(testCoin), BOB.addr),
  				"invalid deposit sum"
  			);
  		}
  	}
  // ****************
// **************************************

// **************************************
// *****       CONTRACT OWNER       *****
// **************************************
  // ****************
  // * TsunamiVault *
  // ****************
  	contract Unit_switchPause is Deployed {
  		function test_revertWhen_callerNotOwner() public {
  			vm.prank(EVE.addr);
				vm.expectRevert(
				  abi.encodeWithSelector(
				    IERC173.IERC173_NOT_OWNER.selector,
				    EVE.addr
				  )
				);
				testContract.switchPause();
  		}
  		function test_switchPause_updateStateAsExpected() public {
  			vm.startPrank(ADMIN.addr);
  			assertEq(
  				testContract.state(),
  				testContract.INACTIVE(),
  				"invalid initial state"
  			);
  			testContract.switchPause();
  			assertEq(
  				testContract.state(),
  				testContract.ACTIVE(),
  				"invalid transitional state"
  			);
  			testContract.switchPause();
  			assertEq(
  				testContract.state(),
  				testContract.INACTIVE(),
  				"invalid final state"
  			);
  			vm.stopPrank();
  		}
  	}
  	contract Unit_whitelistToken is Deployed {
  		function test_revertWhen_callerNotOwner() public {
  			vm.prank(EVE.addr);
				vm.expectRevert(
				  abi.encodeWithSelector(
				    IERC173.IERC173_NOT_OWNER.selector,
				    EVE.addr
				  )
				);
				testContract.whitelistToken(address(testCoin), true);
  		}
  		function test_revertWhen_tokenIsAddressZero() public {
  			vm.prank(ADMIN.addr);
  			vm.expectRevert(TsunamiVault.INVALID_TOKEN.selector);
  			testContract.whitelistToken(address(0), true);
  		}
  		function test_revertWhen_tokenIsNotERC20() public {
  			vm.prank(ADMIN.addr);
  			vm.expectRevert(TsunamiVault.INVALID_TOKEN.selector);
  			testContract.whitelistToken(address(this), true);
  		}
  		function test_whitelistToken_updateWhitelistedToken() public {
  			vm.startPrank(ADMIN.addr);
  			assertEq(
  				testContract.whitelistedToken(address(testCoin)),
  				false,
  				"invalid initial whitelisting status"
  			);
  			testContract.whitelistToken(address(testCoin), true);
  			assertEq(
  				testContract.whitelistedToken(address(testCoin)),
  				true,
  				"invalid transitional whitelisting status"
  			);
  			testContract.whitelistToken(address(testCoin), false);
  			assertEq(
  				testContract.whitelistedToken(address(testCoin)),
  				false,
  				"invalid final whitelisting status"
  			);
  			vm.stopPrank();
  		}
  	}
  // ****************
// **************************************

// **************************************
// *****            VIEW            *****
// **************************************
  // ****************
  // * TsunamiVault *
  // ****************
  	contract InitialDeposit is Deployed {
  		function test_initialDeposit_isZero(address coin, address user) public {
  			assertEq(
  				testContract.userBalance(coin, user),
  				0,
  				"invalid initial deposit"
  			);
  		}
  	}
  // ****************
// **************************************
