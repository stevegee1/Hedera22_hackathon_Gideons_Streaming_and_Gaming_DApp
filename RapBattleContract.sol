//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//this is a voting contract

contract Ballotvote {
    address public chairperson;
    Proposal[] public proposalArray;
    mapping(address => Voter) public addressToEachVoter;

    //creating a struct for Voter
    struct Voter {
        uint256 vote;
        bool isVoted; //check if each voter have voted or not
        uint256 weight; //power to vote
    }
    //Creating a struct object for each proposal
    struct Proposal {
        string name; // name of the proposal
        uint256 voteCount; //number of votes for each proposal
    }

    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        for (uint256 i; i < proposalNames.length; i++) {
            proposalArray.push(
                Proposal({name: proposalNames[i], voteCount: 0})
            );
        }
        addressToEachVoter[chairperson].weight = 1;
    }

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

    function vote(uint256 proposals) public {
        Voter storage sender = addressToEachVoter[msg.sender];
        require(
            sender.weight != 0,
            "this address does not have the right to vote"
        );
        require(!sender.isVoted, "Already voted!");
        sender.isVoted = true;
        sender.vote = proposals;
        proposalArray[proposals].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < proposalArray.length; i++) {
            if (proposalArray[i].voteCount > winningVoteCount) {
                winningVoteCount = proposalArray[i].voteCount;
                winningProposal_ = i;
            }
        }
        return winningProposal_;
    }

    function winningName() public view returns (string memory winningName_) {
        require(msg.sender == chairperson, "fuck off!");
        winningName_ = proposalArray[winningProposal()].name;
        return winningName_;
    }
}
