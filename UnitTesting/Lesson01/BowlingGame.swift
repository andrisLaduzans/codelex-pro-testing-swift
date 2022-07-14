//
//  BowlingGame.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 14/07/2022.
//
/*
 Bowling Rules
 The game consists of 10 frames. In each frame the player has two rolls to knock down 10 pins. The score for the frame is the total number of pins knocked down, plus bonuses for strikes and spares.

 A spare is when the player knocks down all 10 pins in two rolls. The bonus for that frame is the number of pins knocked down by the next roll.

 A strike is when the player knocks down all 10 pins on his first roll. The frame is then completed with a single roll. The bonus for that frame is the value of the next two rolls.

 In the tenth frame a player who rolls a spare or strike is allowed to roll the extra balls to complete the frame. However no more than three balls can be rolled in tenth frame.
 
 More on rules: https://www.rookieroad.com/bowling/how-does-scoring-work/

 Requirements
 Write a class Game that has two methods:

 void roll(int) is called each time the player rolls a ball. The argument is the number of pins knocked down.
 int score() returns the total score for that game.
 */

import Foundation

struct BowlingGame {
    private(set) var frameIndex: Int = 0
    private(set) var frame: [BowlingGameFrameItem] = []
    private(set) var isGameOver: Bool = false
    
    mutating func roll(pinsKnocked: Int) throws -> Void {
        if isGameOver {
            throw BowlingGameError.gameIsOver
        }
        
        if frameIndex + 1 > frame.count {
            frame.append(BowlingGameFrameItem())
        }
        
        var currentFrame = frame[frameIndex]
        
        currentFrame.pins -= pinsKnocked
    
        if currentFrame.pins < 0 {
            throw BowlingGameError.invalidRollPinCount(availablePinCount: currentFrame.pins)
        }
        
        if frameIndex > 0 {
            addBonuses(points: pinsKnocked)
        }
        
        let rollIndex = currentFrame.rollCount
        currentFrame.rolls[rollIndex] = pinsKnocked
        var isStrike = rollIndex == 0 && pinsKnocked == 10
        
        let nextRollIndex = rollIndex + 1
        currentFrame.rollCount = nextRollIndex
        
        if frameIndex == 9 {
            if isStrike {
                print("nullify is strike")
                currentFrame.pins = 10
                isStrike = false
            }
            
            let isSpare = rollIndex == 1 && currentFrame.pins == 0
            if isSpare && currentFrame.rolls.count <= 2 {
                print("is spare! adding extra roll")
                currentFrame.rolls += [0]
                
                if rollIndex < 3 {
                    print("adding more pins")
                    currentFrame.pins = 10
                }
            }
        }
    
        frame[frameIndex] = currentFrame
        if isStrike || nextRollIndex >= currentFrame.rolls.count {
            frameIndex += 1
            if(frameIndex >= 10){
                isGameOver = true
            }
        }
    }
    
    func score() -> Int {
        let result = frame.reduce(0) { acc, item in
            var points = item.rolls.reduce(0, +)
            points += item.bonusPoints
            return acc + points
        }
        
        return result
    }
    
    mutating private func addBonuses(points: Int) -> Void {
        let previousFrameIndex = frameIndex - 1
        let wasStrike = frame[previousFrameIndex].rolls[0] == 10
        let wasSpare = frame[previousFrameIndex].rolls.reduce(0, +) == 10
        if wasStrike || wasSpare {
            frame[previousFrameIndex].bonusPoints = points
        }
    }
}

struct BowlingGameFrameItem: Equatable {
    var pins: Int
    var rollCount: Int = 0
    var rolls: [Int]
    var bonusPoints: Int
    
    init(rolls: [Int] = [0, 0], bonusPoints: Int = 0, rollIndex: Int = 0, pins: Int = 10) {
        self.rolls = rolls
        self.bonusPoints = bonusPoints
        self.rollCount = rollIndex
        self.pins = pins
    }
}

enum BowlingGameError: Error, Equatable {
    case invalidRollPinCount(availablePinCount: Int)
    case gameIsOver
}
