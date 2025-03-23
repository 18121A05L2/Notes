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
    // This pattern is for only dynamic arrays

    uint256[] public storageArray;

    function addElement(uint256 value) public {
        storageArray.push(value);
    }

    function getStorageElement(uint256 index) public view returns (uint256) {
        uint256 element;
        assembly {
            let slot := storageArray.slot // here first slot - 0x0
            let arrayStart := keccak256(slot, 0x20)
            let elementLocation := add(arrayStart, index)
            //  elementLocation := add(storageArray.slot, index) - for fixed size arrays
            // Fixes size arrays : This is because these data will be in the slots and wont be in the dynamic locations
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

// ------------------------------- Returning a struct instead of multiple values ( Optimized way ) -------------------

contract ExampleOptimized {
    struct UserData {
        uint256 age;
        uint256 balance;
        address wallet;
    }

    uint256 public age;
    uint256 public balance;
    address public wallet;

    function getUserData() external view returns (UserData memory) {
        return UserData(age, balance, wallet);
    }
}
// Solidity packs all values into a single memory slot instead of allocating separate memory slots for each variable.
// Instead of multiple memory allocations, it creates only one memory slot for the struct.
// Lower stack-to-memory conversion overhead.

// ----------------------------------------------------------------------------------------------

contract NFT {
    // ex : data:application/json;base64,eyJuYW1lIjoiUHVwcHkgUmFmZmxlIiwgImRlc2NyaXB0aW9uIjoiQW4gYWRvcmFibGUgcHVwcHkhIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogInJhcml0eSIsICJ2YWx1ZSI6IGNvbW1vbn1dLCAiaW1hZ2UiOiJpcGZzOi8vUW1Tc1lSeDNMcERBYjFHWlFtN3paMUF1SFpqZmJQa0Q2SjdzOXI0MXh1MW1mOCJ9
    function _baseURI() internal pure returns (string memory) {
        return "data:application/json;base64,";
    }
    // function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    //     require(_exists(tokenId), "PuppyRaffle: URI query for nonexistent token");

    //     uint256 rarity = tokenIdToRarity[tokenId];
    //     string memory imageURI = rarityToUri[rarity];
    //     string memory rareName = rarityToName[rarity];

    //     return string(
    //         abi.encodePacked(
    //             _baseURI(),
    //             Base64.encode(
    //                 bytes(
    //                     abi.encodePacked(
    //                         '{"name":"',
    //                         name(),
    //                         '", "description":"An adorable puppy!", ',
    //                         '"attributes": [{"trait_type": "rarity", "value": ',
    //                         rareName,
    //                         '}], "image":"',
    //                         imageURI,
    //                         '"}'
    //                     )
    //                 )
    //             )
    //         )
    //     );
    // }
}

// ------------------------------------ SelfDestructs victim -------------------------------------

/**
 * @title SelfDestructer
 * @notice This contract contains a function that calls selfdestruct.
 *         When executed via delegatecall, it will self-destruct the calling contract.
 */
contract SelfDestructer {
    function doSelfDestruct(address payable beneficiary) public {
        // When delegatecalled, selfdestruct will affect the calling contract
        selfdestruct(beneficiary);
    }
}

/**
 * @title Victim
 * @notice This contract does not contain any direct selfdestruct calls.
 *         However, it provides a function that uses delegatecall so that external code
 *         (such as from SelfDestructer) can be executed in its context.
 */
contract Victim {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Executes a delegatecall to the target contract with the provided data.
     * @dev When target is SelfDestructer and data is the encoded call to doSelfDestruct,
     *      this function will cause the Victim contract to self-destruct.
     * @param target The contract whose code will be executed via delegatecall.
     * @param data The calldata to send to the target.
     */
    function executeDelegatecall(address target, bytes calldata data)
        public
        returns (bool, bytes memory)
    {
        require(msg.sender == owner, "Not owner");
        return target.delegatecall(data);
    }
}

// ----------------------------------------------------------------------------------------------------