// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Fmt} from "../src/Fmt.sol";

contract FmtTest is Test {
    function setUp() public {
    }

    function assertFmt(string memory expected, bytes memory args) internal pure {
        assertEq(expected, Fmt.fmt(args));
    }

    function testFmt() public {
        assertFmt("", abi.encode());
    }
}
