// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstate {
    address public owner;

    struct Property {
        uint id;
        string location;
        uint price;
        address currentOwner;
        bool isAvailable;
    }

    uint public propertyCount = 0;
    mapping(uint => Property) public properties;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProperty(string memory _location, uint _price) public onlyOwner {
        propertyCount++;
        properties[propertyCount] = Property(propertyCount, _location, _price, owner, true);
    }

    function buyProperty(uint _id) public payable {
        Property storage property = properties[_id];
        require(property.isAvailable, "Property is not available");
        require(msg.value >= property.price, "Insufficient payment");

        address prevOwner = property.currentOwner;
        property.currentOwner = msg.sender;
        property.isAvailable = false;

        payable(prevOwner).transfer(msg.value);
    }

    function resellProperty(uint _id, uint _newPrice) public {
        Property storage property = properties[_id];
        require(msg.sender == property.currentOwner, "Only current owner can resell this property");
        require(!property.isAvailable, "Property is already available");

        property.price = _newPrice;
        property.isAvailable = true;
    }

    function getProperty(uint _id) public view returns (string memory, uint, address, bool) {
        Property storage property = properties[_id];
        return (property.location, property.price, property.currentOwner, property.isAvailable);
    }

    function getAvailableProperties() public view returns (uint[] memory) {
        uint count = 0;
        for (uint i = 1; i <= propertyCount; i++) {
            if (properties[i].isAvailable) {
                count++;
            }
        }

        uint[] memory available = new uint[](count);
        uint index = 0;
        for (uint i = 1; i <= propertyCount; i++) {
            if (properties[i].isAvailable) {
                available[index] = properties[i].id;
                index++;
            }
        }

        return available;
    }

    //Remove a property from listing
    function removeProperty(uint _id) public onlyOwner {
        require(properties[_id].id != 0, "Property does not exist");
        delete properties[_id];
    }
}
