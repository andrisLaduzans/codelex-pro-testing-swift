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
    
    func test_roll_spare_and_strike_combos() throws {
        //1st frame
        try bowlingGame.roll(pinsKnocked: 10)
        //2nd frame
        try bowlingGame.roll(pinsKnocked: 5)
        try bowlingGame.roll(pinsKnocked: 5)
        //3rd frame
        try bowlingGame.roll(pinsKnocked: 0)
        try bowlingGame.roll(pinsKnocked: 0)
        //4th frame
        try bowlingGame.roll(pinsKnocked: 0)
        try bowlingGame.roll(pinsKnocked: 10)
        
        //5th frame
        try bowlingGame.roll(pinsKnocked: 2)
        
        let expectedFrame: [BowlingGameFrameItem] = [
            BowlingGameFrameItem(rolls: [10, 0], bonusPoints: 5, rollIndex: 1, pins: Int(0)),
            BowlingGameFrameItem(rolls: [5, 5], bonusPoints: 0, rollIndex: 2, pins: 0),
            BowlingGameFrameItem(rolls: [0, 0], bonusPoints: 0, rollIndex: 2, pins: 10),
            BowlingGameFrameItem(rolls: [0, 10], bonusPoints: 2, rollIndex: 2, pins: 0),
            BowlingGameFrameItem(rolls: [2, 0], bonusPoints: 0, rollIndex: 1, pins: 8)
        ]
        
        XCTAssertEqual(bowlingGame.frame[0], expectedFrame[0], "should calculate various spare/strike/regualar frame rolls")
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
        print("fr: \(bowlingGame.frame[9])")
        print("ex: \(expectedFrame[9])")
        
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
        print("\(bowlingGame.frame)")
        
        print("frameCount: \(bowlingGame.frameIndex)")
        XCTAssertEqual(bowlingGame.score(), 300, "perfect score result should be 300")
        //    STRIKES ADD DOUBLE FOR NEXT 2 ROLLS!!!
    }
}
