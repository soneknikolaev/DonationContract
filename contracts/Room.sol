// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

struct RoomInfo {
    uint256 donation;
    address owner;
    bool created;
    bool active;
    address[] participants;
}

contract Room {
    event RoomCreated(address initiator, string roomName);

    event RoomUpdated(address initiator, RoomInfo room);

    event RoomDeleted(address initiator, string roomName);

    mapping(string => RoomInfo) internal rooms;
    string[] internal names;

    constructor() {}

    modifier canCreateRoom(string memory roomName) {
        require(rooms[roomName].created != true, "The room with this name is already created");
        require(msg.value >= 1000, "First donation is very small");
        _;
    }

    modifier onlyRoomOwner(string memory roomName) {
        require(rooms[roomName].owner == msg.sender, "You are not owner of the room");
        _;
    }

    function getRoomInfo(string memory roomName) public view returns (RoomInfo memory) {
        return rooms[roomName];
    }

    function createRoom(string memory roomName) public payable canCreateRoom(roomName) {
        rooms[roomName] = RoomInfo({
            donation: msg.value,
            owner: msg.sender,
            created: true,
            active: false,
            participants: new address[](0)
        });

        rooms[roomName].participants.push(msg.sender);
        names.push(roomName);
        emit RoomCreated(msg.sender, roomName);
    }

    function startRoomFundraising(string memory roomName) public onlyRoomOwner(roomName) {
        rooms[roomName].active = true;
        emit RoomUpdated(msg.sender, rooms[roomName]);
    }

    function finishRoomFundraising(string memory roomName) public onlyRoomOwner(roomName) {
        rooms[roomName].active = false;
        emit RoomUpdated(msg.sender, rooms[roomName]);
    }

    function deleteRoom(string memory roomName) internal {
        string[] memory newNames;
        delete rooms[roomName];

        for(uint i = 0; i < names.length; i++) {
            string storage name = names[i];

            if (keccak256(abi.encodePacked(name)) != keccak256(abi.encodePacked(roomName))) {
                newNames[i] = name;
            }
        }

        names = newNames;
        emit RoomDeleted(msg.sender, roomName);
    }

    function transferRoomOwnership(string memory roomName, address newOwner) public onlyRoomOwner(roomName) {
        rooms[roomName].owner = newOwner;
        emit RoomUpdated(msg.sender, rooms[roomName]);
    }
}