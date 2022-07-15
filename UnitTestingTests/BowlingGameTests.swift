//
//  BowlingGameTests.swift
//  UnitTestingTests
//
//  Created by Andris Laduzans on 14/07/2022.
//

import XCTest
@testable import UnitTesting

class BowlingGameTests: XCTestCase {

    var bowlingGame: BowlingGame!
    
    override func setUp() {
        super.setUp()
        bowlingGame = BowlingGame()
    }
    
    override func tearDown() {
        bowlingGame = nil
        super.tearDown()
    }
    
    func test_error_cannot_roll_more_than_available_pins() {
        let expectedError = BowlingGameError.invalidRollPinCount(availablePinCount: -1)
        var error: BowlingGameError!
        
        XCTAssertThrowsError(try bowlingGame.roll(pinsKnocked: 11), "roll method cannot exceed pin coun that is available") { thrownError in
            error = thrownError as? BowlingGameError
        }
        
        XCTAssertEqual(error, expectedError, "Thrown error must be of type BowlingGameError")
    }
    
    func test_add_bonus_points_with_spares() throws {
        //1st frame
        try bowlingGame.roll(pinsKnocked: 5)
        try bowlingGame.roll(pinsKnocked: 5)
        //2nd frame
        try bowlingGame.roll(pinsKnocked: 3)
        try bowlingGame.roll(pinsKnocked: 3)
        //3rd frame
        try bowlingGame.roll(pinsKnocked: 4)
        
        let expectedFrame: [BowlingGameFrameItem] = [
            BowlingGameFrameItem(rolls: [5, 5], bonusPoints: 3, rollIndex: 2, pins: 0),
            BowlingGameFrameItem(rolls: [3, 3], bonusPoints: 0, rollIndex: 2, pins: 4),
            BowlingGameFrameItem(rolls: [4, 0], bonusPoints: 0, rollIndex: 1, pins: 6)
        ]
        
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "bonus from  spare should only occour once")
    }
    
    func test_add_multiple_strike_bonuses() throws {
        //1st frame
        try bowlingGame.roll(pinsKnocked: 10)
        //2nd frame
        try bowlingGame.roll(pinsKnocked: 10)
        //3rd frame
        try bowlingGame.roll(pinsKnocked: 10)
        
        let expectedFrame: [BowlingGameFrameItem] = [
            BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 20, rollIndex: 1, pins: 0),
            BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 10, rollIndex: 1, pins: 0),
            BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 0, rollIndex: 1, pins: 0)
        ]
        
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "bonuses should be added twice on next 2 rolls")
    }
    
    func test_add_bonuses_after_strike() throws {
        //1st frame
        try bowlingGame.roll(pinsKnocked: 10)
        //2nd frame
        try bowlingGame.roll(pinsKnocked: 5)
        try bowlingGame.roll(pinsKnocked: 5)
        //3rd frame
        try bowlingGame.roll(pinsKnocked: 3)
        
        let expectedFrame: [BowlingGameFrameItem] = [
            BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 10, rollIndex: 1, pins: 0),
            BowlingGameFrameItem(rolls: [5, 5], bonusPoints: 3, rollIndex: 2, pins: 0),
            BowlingGameFrameItem(rolls: [3, 0], bonusPoints: 0, rollIndex: 1, pins: 7)
        ]
        
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "first strike should get bonus from next 2 rolls, next frame is spare so it gets bonus from 3rd frame")
    }
    
    func test_roll_spare_and_strike_combos() throws {
        //1st frame
        try bowlingGame.roll(pinsKnocked: 10)
        //2nd frame
        try bowlingGame.roll(pinsKnocked: 5)
        try bowlingGame.roll(pinsKnocked: 5)
        //3rd frame
        try bowlingGame.roll(pinsKnocked: 10)
        //4th frame
        try bowlingGame.roll(pinsKnocked: 0)
        try bowlingGame.roll(pinsKnocked: 8)
        
        //5th frame
        try bowlingGame.roll(pinsKnocked: 1)
        
        let expectedFrame: [BowlingGameFrameItem] = [
            BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 10, rollIndex: 1, pins: 0),
            BowlingGameFrameItem(rolls: [5, 5], bonusPoints: 10, rollIndex: 2, pins: 0),
            BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 8, rollIndex: 1, pins: 0),
            BowlingGameFrameItem(rolls: [0, 8], bonusPoints: 0, rollIndex: 2, pins: 2),
            BowlingGameFrameItem(rolls: [1, 0], bonusPoints: 0, rollIndex: 1, pins: 9)
        ]
        
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "should calculate various spare/strike/regualar frame rolls")
    }
    
    func playTillLastRound() throws -> [BowlingGameFrameItem] {
        for _ in 0..<18 {
            try bowlingGame.roll(pinsKnocked: 2)
        }
        
        let expectedFrame: [BowlingGameFrameItem] = Array(repeating: BowlingGameFrameItem(rolls: [2, 2], bonusPoints: 0, rollIndex: 2, pins: 6), count: 9)
        return expectedFrame
    }
    
    func test_last_frame_regular_rolls() throws {
        var expectedFrame = try playTillLastRound()
        
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "should generate game with 9 played frames")
        
        //10th frame
        try bowlingGame.roll(pinsKnocked: 2)
        try bowlingGame.roll(pinsKnocked: 2)
        
        expectedFrame.append(BowlingGameFrameItem(rolls: [2, 2], bonusPoints: 0, rollIndex: 2, pins: 6))
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "game should have full 10 frames with 2 rolls in each roll")
        
        XCTAssertEqual(bowlingGame.isGameOver, true, "should be game over if 2 rolls in 10th frame are not strike or spare")
    }
    
    func test_last_frame_with_spare() throws {
        var expectedFrame = try playTillLastRound()
        //10th frame
        try bowlingGame.roll(pinsKnocked: 0)
        try bowlingGame.roll(pinsKnocked: 10)
        
        expectedFrame.append(BowlingGameFrameItem(rolls: [0, 10, 0], bonusPoints: 0, rollIndex: 2, pins: 10))
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "should have 10th frame with spare and one extra roll available")
        
        XCTAssertEqual(bowlingGame.isGameOver, false, "game should not be over if spare achieved in one of last 2 rolls")
    }
    
    func test_last_frame_with_double_strike() throws {
        var expectedFrame = try playTillLastRound()
        //10frame 1st roll
        try bowlingGame.roll(pinsKnocked: 10)
        expectedFrame.append(BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 0, rollIndex: 1))
        
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "should have 10th frame with 1 roll left")
        
        //10frame 2nd roll
        try bowlingGame.roll(pinsKnocked: 10)
        expectedFrame[9] = BowlingGameFrameItem(rolls: [10, 10, 0], bonusPoints: 0, rollIndex: 2, pins: 10)
        
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "should get another another 3rd roll after second strike")
        XCTAssertEqual(bowlingGame.isGameOver, false, "game should not be over")
        
        //10frame 3rd roll
        try bowlingGame.roll(pinsKnocked: 10)
        expectedFrame[9] = BowlingGameFrameItem(rolls: [10, 10, 10], bonusPoints: 0, rollIndex: 3, pins: 0)
        XCTAssertEqual(bowlingGame.frame, expectedFrame, "last roll + 10 points, no more pins")
        XCTAssertEqual(bowlingGame.isGameOver, true, "game is over")
    }
    
    func test_throws_if_roll_tried_after_game_over() throws {
        let _ = try playTillLastRound()
        //10th frame
        try bowlingGame.roll(pinsKnocked: 0)
        try bowlingGame.roll(pinsKnocked: 0)
        
        let expectedError = BowlingGameError.gameIsOver
        var error: BowlingGameError!
        
        XCTAssertThrowsError(try bowlingGame.roll(pinsKnocked: 11), "cannot roll after game over") { thrownError in
            error = thrownError as? BowlingGameError
        }
        
        XCTAssertEqual(error, expectedError, "Thrown error must be of type BowlingGameError.gameOver")
    }
    
    func test_result_in_perfect_game() throws {
        for _ in 0..<12 {
            try bowlingGame.roll(pinsKnocked: 10)
        }
        
        XCTAssertEqual(bowlingGame.score(), 300, "perfect score result should be 300")
    }
    
    func test_score_mix_of_spares_and_strikes() throws {
        //1st frame
        try bowlingGame.roll(pinsKnocked: 10)
        //score: 10 + 3 + 7 = 20
        //2nd frame
        try bowlingGame.roll(pinsKnocked: 3)
        try bowlingGame.roll(pinsKnocked: 7)
        //score: 10 + 10 = 20
        //3rd frame
        try bowlingGame.roll(pinsKnocked: 10)
        //score: 10 + 0 + 0 = 10
        //4th frame
        try bowlingGame.roll(pinsKnocked: 0)
        try bowlingGame.roll(pinsKnocked: 0)
        //score: 0
        //total: 50
        let expectedScore = 50
        XCTAssertEqual(bowlingGame.score(), expectedScore)
    }
    
    func test_score_if_spare_on_last_throw() throws {
        for _ in 0..<21 {
            try bowlingGame.roll(pinsKnocked: 5)
        }
        
        XCTAssertEqual(bowlingGame.score(), 150, "each frame gets 10 points and spare of 5, 15 x 10 = 150")
    }
}
