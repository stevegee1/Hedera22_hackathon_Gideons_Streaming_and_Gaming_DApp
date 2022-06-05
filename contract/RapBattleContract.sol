//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//This is a voting contract

contract RapBattleContract{
    //This is the address that deploys the contract
    address public chairperson; //This can be a DAO contract

    //This is an array of Rappers/Constestants' struct
    Contestant[] public contestantsArray;

    //This maps the address of each voter to its struct(Voter).
    //Our Revenue contract can automatically transfer Hbar to the hashgraph wallet
    //of each registered voter
    mapping(address => Voter) public addressToEachVoter;

    //creating a struct for Voter
    struct Voter {
        uint256 vote;
        bool isVoted; //check if each voter have voted or not
        uint256 weight; //power to vote
    }
    //Creating a struct object for each contestant
    struct Contestant {
        string name; // name of the proposal
        uint256 voteCount; //number of votes for each proposal
    }

    constructor(string[] memory contestantNames) {
        //the chairperson is the address that deployed this contract
        chairperson = msg.sender;

        //We looped through to add each contestantName to the array of contestants
        for (uint256 i; i < contestantNames.length; i++) {
            contestantsArray.push(
                Contestant({name: contestantNames[i], voteCount: 0})
            );
        }
        //the address, chairperson is given the power to vote
        addressToEachVoter[chairperson].weight = 1;
    }

    //This function can only be called by the chairperson
    //It simply gives voting right to addresses
    //It checks if the address has voted before
    //It checks if the voting power is 0(which implies no voting power for that address)
    //then it gives the address a voting power of "1"
    function giveRightToVote(address potentialVoter) public {
        require(
            msg.sender == chairperson,
            "Only the chairperson can give access to vote"
        );
        require(
            !addressToEachVoter[potentialVoter].isVoted,
            "This address has already voted!"
        );
        require(addressToEachVoter[potentialVoter].weight == 0);
        addressToEachVoter[potentialVoter].weight = 1;
    }

    //This function ensures voters cast their votes for the contestant of their choice
    //The voting power of the address that calls the function must not be equal to zero
    //the address cannot vote twice. It must be once
    function vote(uint256 proposals) public {
        Voter storage sender = addressToEachVoter[msg.sender];
        require(
            sender.weight != 0,
            "this address does not have the right to vote"
        );
        require(!sender.isVoted, "Already voted!");
        sender.isVoted = true;
        sender.vote = proposals;
        contestantsArray[proposals].voteCount += sender.weight;
    }

    //This function returns the winning contestant which can be seen by any(indeed public and
    // transparent)
    function winningContestant()
        public
        view
        returns (string memory winningName_)
    {
        uint256 winningProposal_ = 0;
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < contestantsArray.length; i++) {
            if (contestantsArray[i].voteCount > winningVoteCount) {
                winningVoteCount = contestantsArray[i].voteCount;
                winningProposal_ = i;
            }
        }
        return contestantsArray[winningProposal_].name;
    }

    //this function can only be called by the chairperson
    //It handles the result of the voting
    //It handles the rare case where the voting ends in tie,
    //it returns "the result is debatable"
    function winningName() public view returns (string memory winningName_) {
        require(msg.sender == chairperson, "voting is in process");
        uint256 i = 0;
        while (i < (contestantsArray.length - 1)) {
            if (
                contestantsArray[i].voteCount == contestantsArray[i++].voteCount
            ) {
                return ("the result is debatable");
            }
        }

        winningName_ = winningContestant();
        return winningName_;
    }
}
