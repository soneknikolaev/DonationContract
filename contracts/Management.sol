// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Room.sol";

contract Management is Room, Ownable {
    using SafeMath for uint256;

    function _getAllDonations() private view returns(uint256) {
        uint256 total;

        for(uint i = 0; i < names.length; i++) {
            string storage name = names[i];

            total = total.add(
                rooms[name].donation
            );
        }

        return total;
    }

    function _getFreeBalance() private view onlyOwner returns(uint256) {
        return address(this).balance.sub(
            _getAllDonations()
        );
    }

    function withdrawFreeBalance() public payable onlyOwner {
        payable(owner()).transfer(_getFreeBalance());
    }

    function _canDistructContract() private view returns (bool) {
        bool canDistruct = true;

        for(uint i = 0; i < names.length; i++) {
            string storage name = names[i];

            if (rooms[name].active == true) {
                canDistruct = false;
                break;
            }
        }

        return canDistruct;
    }

    function distruct() public payable onlyOwner {
        require(_canDistructContract(), "You cannot distruct contract until one of the room is active");
        selfdestruct(payable(owner()));
    }
}