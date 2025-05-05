// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract HelloWorld {

    string public message= 'Hello World';

    function setMessage(string memory _message) public {
        message = _message;
    }
}