// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Mock_ERC20 is ERC20 {
  constructor() ERC20('Name', 'SYMBOL') {}

  function mint(uint256 amount_) public {
    if (amount_ > 0) {
      _mint(msg.sender, amount_);
    }
  }
}
