// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ISquad.sol";

contract SquadActions {
    address squadFactoryAddress;
    mapping(address => SquadMeta) squads;

    struct SquadMeta {
        bool exists;
        mapping (address => uint) investments;
        mapping(address => bool) claimed;
        uint investorCount;
        address acquiredBy;
    }

    event SquadAdded(address indexed squadAddress);
    event SquadActivated(address indexed squadAddress);

    constructor(address _squadFactoryAddress) {
        squadFactoryAddress = _squadFactoryAddress;
    }

    function getInvestorCount(address _squadAddress) public view returns (uint) {
        SquadMeta storage squadMeta = squads[_squadAddress];
        return squadMeta.investorCount;
    }

    function addSquad(address _squadAddress) public {
        require(msg.sender == squadFactoryAddress, "not allowed");
        require(squads[_squadAddress].exists == false, "already exists");
        SquadMeta storage squadMeta = squads[_squadAddress];
        squadMeta.exists = true;
        emit SquadAdded(_squadAddress);
    }

    function getSquad(address _squadAddress) internal view returns (ISquad) {
        require(squads[_squadAddress].exists == true, "not found");
        return ISquad(_squadAddress);
    }

    function activate(address _squadAddress) public payable {
        ISquad squad = getSquad(_squadAddress);
        
        require(squad.status() == 1, "cannot activate");
        require(msg.sender == squad.initiator(), "not allowed");
        uint target = squad.maxFundSize();
        require(msg.value == (target * 10 / 100), "invalid contribution");
        
        SquadMeta storage squadMeta = squads[_squadAddress];
        squadMeta.investments[msg.sender] = (target * 10 / 100);
        squadMeta.investorCount = 1;
        squad.updateCurrentInvestment(squadMeta.investments[msg.sender]);
        squad.updateStatus(2);

        emit SquadActivated(_squadAddress);
    }
}