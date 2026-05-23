// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CommitLog} from "src/CommitLog.sol";

contract CommitLogTest is Test {
    CommitLog public commitLog;

    function setUp() public {
        commitLog = new CommitLog();
    }

    function testRecordCommitDecision() public {
        commitLog.recordDecision("tx-001", CommitLog.Decision.COMMIT);
        assertEq(uint(commitLog.getDecision("tx-001")), uint(CommitLog.Decision.COMMIT));
    }

    function testRecordAbortDecision() public {
        commitLog.recordDecision("tx-002", CommitLog.Decision.ABORT);
        assertEq(uint(commitLog.getDecision("tx-002")), uint(CommitLog.Decision.ABORT));
    }

    function testCannotRecordInvalidDecision() public {
        vm.expectRevert(bytes("Invalid decision"));
        commitLog.recordDecision("tx-003", CommitLog.Decision.UNKNOWN);
    }

    function testCannotRecordSameDecisionTwice() public {
        commitLog.recordDecision("tx-004", CommitLog.Decision.COMMIT);
        vm.expectRevert(bytes("Decision already recorded"));
        commitLog.recordDecision("tx-004", CommitLog.Decision.ABORT);
    }

    function testDecisionRecordedEvent() public {
        vm.expectEmit(true, true, true, true);
        emit CommitLog.DecisionRecorded("tx-005", CommitLog.Decision.ABORT, block.timestamp, address(this));
        commitLog.recordDecision("tx-005", CommitLog.Decision.ABORT);
    }
}
