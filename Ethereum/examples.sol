// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Examples {
    // --------------------- Decoding an encode packed data tyes -----------
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

    // --------------------- Array storage slot ---------------------------

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

// -------------------------------- Proxy contracts ( Inherited contract ) -----------------------------
contract A {
    uint256 a = 2;
}

contract B {
    uint256 b = 3;
}

contract BaseContract is A, B {
    uint256 c = 4;
    address public add = 0xE959A2c1c3F108697c244b98C71803b6DcD77764;

    function getVariable(uint256 _temp) public view returns (address) {
        address d;
        assembly {
            d := sload(_temp)
        }
        return d;
    }
}
// For base Contract , Store slot at 0 will be allocated to a and for Storage slot at 1 will be allocated to b

//-----------------------------------------BitMask--------------------------------
//--> The easiest way is to take a uint256 variable and use all 256 bits of it to represent individual booleans. To get an individual boolean from a uint256 , use this function:
contract BitMask {
    function getBoolean(uint256 _packedBools, uint256 _boolNumber) public view returns (bool) {
        uint256 flag = (_packedBools >> _boolNumber) & uint256(1);
        return (flag == 1 ? true : false);
    }
    //To set or clear a bool, use:

    function setBoolean(uint256 _packedBools, uint256 _boolNumber, bool _value) public view returns (uint256) {
        if (_value) {
            return _packedBools | uint256(1) << _boolNumber;
        } else {
            return _packedBools & ~(uint256(1) << _boolNumber);
        }
    }
    // With this technique, you can store 256 booleans in one storage slot. If you try to pack bool normally (like in a struct) then you will only be able to fit 32 bools in one slot. Use this only when you want to store more than 32 booleans.
}
