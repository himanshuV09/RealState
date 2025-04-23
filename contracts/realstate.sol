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

    // Function to add a new property
    function addProperty(string memory _location, uint _price) public onlyOwner {
        propertyCount++;
        properties[propertyCount] = Property(propertyCount, _location, _price, owner, true);
    }

    // Function to buy a property
    function buyProperty(uint _id) public payable {
        Property storage property = properties[_id];
        require(property.isAvailable, "Property is not available");
        require(msg.value >= property.price, "Insufficient payment");

        address prevOwner = property.currentOwner;
        property.currentOwner = msg.sender;
        property.isAvailable = false;

        payable(prevOwner).transfer(msg.value);
    }

    //Function to mark a property for resale by its current owner
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
}
