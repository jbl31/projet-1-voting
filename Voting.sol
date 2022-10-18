// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/a1948250ab8c441f6d327a65754cb20d2b1b4554/contracts/access/Ownable.sol";

/**
* Address list:
* Owner: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
* Voter 1: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
* Voter 2: 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
* Voter 3: 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
*/

contract Voting is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    mapping(address => Voter) whitelist;

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    address private _owner; // Addresse du propriétaire du contrat (admin)
    uint private winningProposalId; // proposition gagnante
    Proposal[] public proposals; // Liste (tableau) de propositions
    bool proposalRegistrationStarted;
    bool proposalRegistrationEnded;
    bool votingSessionStarted;
    bool votingSessionEnded;


    constructor () {
        proposalRegistrationStarted = true;
    }

    /**
    * Enregistrement en liste blanche
    */
    function registration(address _address) public onlyOwner { //add to whitelist
        require(!whitelist[_address].isRegistered, "Your address have been already registered");

        whitelist[_address].isRegistered = true;

        emit VoterRegistered(_address);
    }

    /**
    * Déclenche l'enregistrement des propositions
    */
    function proposalRegistration(string memory _proposal) public {
        require(!proposalRegistrationEnded, "Proposal registration is ended or didn't started");
        require(whitelist[msg.sender].isRegistered,"You have to be registered first");

        Proposal memory newProposal = Proposal({
            description: _proposal,
            voteCount: 0
        });

        proposals.push(newProposal);
        whitelist[msg.sender].votedProposalId = proposals.length - 1;

        emit ProposalRegistered( proposals.length - 1);
    }

    /**
    * Fonction de vote
    */
    function vote(uint proposalId) public {
        require(whitelist[msg.sender].isRegistered, "You have to be registered in order to vote");
        require(!votingSessionEnded, "Voting isn't open");
        require(!whitelist[msg.sender].hasVoted," You voted already");

        whitelist[msg.sender].votedProposalId = proposalId;
        whitelist[msg.sender].hasVoted = true;
        proposals[proposalId].voteCount++;

        emit Voted(msg.sender, proposalId);
        
    }

    /**
    * Compte les votes
    */
    function countVotes() public onlyOwner {
        
        winningProposalId = proposals[0].voteCount;

        for (uint index = 1; index < proposals.length; index ++){
            winningProposalId < proposals[index].voteCount ? winningProposalId = index : winningProposalId = winningProposalId;
        
        }
           
    }

    /**
    * Retourne la proposition gagnante
    */
    function getWinningProposalId() public view returns(uint) {
        return winningProposalId;
       
    }
}
