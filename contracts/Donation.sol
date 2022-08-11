// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Management.sol";

contract Donation is Management {
    event Donated(address initiator, string roomName, uint256 donation);
    
    uint8 constant public COMMISSION = 10;
    using SafeMath for uint256;

    modifier canDonate(string memory roomName) {
        require(rooms[roomName].active, "Room is not active");
        require(msg.value >= 1000, "Donation is very small");
        _;
    }

    function getDonationAfterCommission(string memory roomName) public view returns(uint256) {
        RoomInfo storage room = rooms[roomName];
        return room.donation.sub(room.donation.div(COMMISSION));
    }

    function donate(string memory roomName) public payable canDonate(roomName) {
        rooms[roomName].donation = rooms[roomName].donation.add(msg.value);
        rooms[roomName].participants.push(msg.sender);
        emit Donated(msg.sender, roomName, msg.value);
    }

    function withdraw(string memory roomName, address payable to) public payable onlyRoomOwner(roomName) {
        require(rooms[roomName].active == false, "You mush finish fundraising");

        to.transfer(
            getDonationAfterCommission(roomName)
        );

        deleteRoom(roomName);
    }
}