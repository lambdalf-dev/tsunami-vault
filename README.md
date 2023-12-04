# Tsunami Vault

A take home assignment for applying to a job opportunity with Tsunami.

## Instructions

Write a “Vault” solidity contract.

Requirements:
1) There should be a ‘deposit’, and ‘withdraw’ function that any user can use to deposit and withdraw any whitelisted ERC-20 token on the contract.

2) There should also be two additional functions that only admins can call. 
i) ‘pause/unpause’ function that prevent/enable new deposits or withdrawals from occurring.
ii) whitelistToken that admins call to whitelist tokens

3) The code repository should contain testing for the contract as well. 
i) The repository should also contain instructions in the readme for running tests.

4) The vault should be usable by any number of users.

The test will be evaluated on:
a) code cleanliness and clarity
b) its readme
c) if it runs as expected with tests
d) The ease of a potential user interacting with the contract
e) if it is tested properly
f) if every requirement is met

## Running the repo

Here's a brief guide as to how run this repo.

First, you make sure you have [foundry](https://github.com/foundry-rs/foundry) on your machine.
Then clone the repo and run:
```
yarn install
forge install
```

### Running the tests

To run the tests, you can run either of the following commands:

- `yarn test` runs the full test suite
- `yarn test:verbose` runs the full test suite, displaying all internal calls, etc...
- `forge test -vvvv --match-test <test case name>` runs a given test case, displaying all internal calls, etc...

### Linting the contracts with forge fmt

To run a linter check, you can run:
```
yarn lint
```

### Test coverage

To run coverage, run the following commands:

- `yarn coverage` runs a coverage report and generates a lcov file
- `yarn coverage:html` converts the lcov file into an html coverage report

## Contents

- `src`: The list of contracts included in the library.
- `lib`: A list of libraries necessary to run forge test suite.
- `test`: The foundry test suite for the repository.
