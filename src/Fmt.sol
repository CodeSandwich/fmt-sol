// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Fmt {
    function fmt(bytes memory args) internal pure returns (string memory result) {
        assembly {
            // let outPtr := add(32, mload(64))

            result := mload(64)
            mstore(result, 0)
            mstore(64, add(result, 32))

            // let currArg = add(32, args)

            // let inPtr := template.offset
            // let inPtrEnd := add(inPtr, template.length)

            // calldataload 3
            //     push248 3 shr 3
            //     push255 3 and 3
            //     push 0 2 byte 3

            //     // %%
            //     // %s
            //     // % ??? [symbol]

            // // let inPtrEnd := template.offset
            // // let inPtr := add(inPtrEnd, 32)
            // // inPtrEnd := add(inPtr, calldataload(inPtrEnd))

            // let argsPtr := args.offset

            // // template := add(template, calldataload(template))
            // // let templateEnd := add(template, add(32, mload(template)))
            // // template := add(template, 32)

            // // Store "A"
            // // mstore8(outPtr, 65)
            // mstore8(outPtr, template.length)
            // outPtr := add(outPtr, 1)

            // mstore8(outPtr, template.offset)
            // outPtr := add(outPtr, 1)

            // mstore(outPtr, calldataload(template.offset))
            // outPtr := add(outPtr, 1)

            // // Store the returned string offset
            // // mstore(0, 32)
            // mstore(0, 320)
            // // Store the returned string length
            // mstore(32, sub(outPtr, 64))
            // // Zero-pad the string data
            // mstore(outPtr, 0)
            // // Return the memory range rounded up to 32 bytes
            // return(0, shl(5, shr(5, add(outPtr, 31))))
        }
    }
}
