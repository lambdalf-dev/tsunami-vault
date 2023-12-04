// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import { Test } from "forge-std/Test.sol";

contract Accounts is Test {
  // Default user
  Account public ALICE;
  // Other user
  Account public BOB;
  // Default attacker
  Account public EVE;
  // Default admin
  Account public ADMIN;

  /// @dev Generates a user, labels its address, and funds it with test assets.
  function _createUser(string memory name) internal returns (Account memory account) {
    account = makeAccount(name);
    vm.deal({ account: account.addr, newBalance: 100 ether });
  }
}

contract Constants {
}

abstract contract TestHelper is Constants, Accounts, ContractHelper {
  function setUp() public virtual {
    ALICE = _createUser("Alice");
    BOB = _createUser("Bob");
    EVE = _createUser("Eve");
    ADMIN = _createUser("Admin");
  }
}
