// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Examples {
    // ------------- Decoding an encode packed data tyes -----------
    function returnData() public pure returns (bytes memory) {
        return abi.encodePacked(uint256(1), uint8(255), "hello");
    }

    function decodePacked() public pure returns (uint256, uint8, string memory) {
        bytes memory packedData = returnData();
        uint256 firstValue;
        uint8 secondValue;
        string memory thirdValue;
        // Decode `uint256`
        assembly {
            firstValue := mload(add(packedData, 32)) // Load first 32 bytes (uint256)
        }
        // Decode `uint8`
        secondValue = uint8(packedData[32]); // The 33rd byte is the `uint8`
        // Decode string (remaining bytes)
        bytes memory tempBytes = new bytes(packedData.length - 33);
        for (uint256 i = 33; i < packedData.length; i++) {
            tempBytes[i - 33] = packedData[i];
        }
        thirdValue = string(tempBytes);
        return (firstValue, secondValue, thirdValue);
    }

    // ------------ Array storage slot ---------------------------

    uint256[] public storageArray;

    function addElement(uint256 value) public {
        storageArray.push(value);
    }

    function getStorageElement(uint256 index) public view returns (uint256) {
        uint256 element;
        assembly {
            let slot := storageArray.slot
            let arrayStart := keccak256(0x0, 0x20)
            let elementLocation := add(arrayStart, index)
            element := sload(elementLocation)
        }
        return element;
    }

    // ---------------------------- Mapping storage slot --------------------------------
    mapping(uint256 => uint256) public storageMap;

    function getMappingValue(uint256 key) public view returns (uint256) {
        uint256 slot;
        bytes32 storedLoc = keccak256(abi.encode(key, 0)); // 0 is the slot number
        assembly {
            slot := sload(storedLoc)
        }
        return slot;
    }
}
