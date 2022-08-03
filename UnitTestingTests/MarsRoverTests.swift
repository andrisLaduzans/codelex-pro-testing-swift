//
//  MarsRoverTests.swift
//  UnitTestingTests
//
//  Created by Andris Laduzans on 16/07/2022.
//

import XCTest
@testable import UnitTesting

class MarsRoverTests: XCTestCase {
    var marsRover: MarsRover!
    
    override func setUp() {
        super.setUp()
        marsRover = MarsRover(point: MarsRoverPoint(x: 0, y: 0), direction: .E, grid: (100, 100))
        do {
            //override randomisation for obstacle generation on mars rover init
            try marsRover.setObstacles(roverPosition: marsRover.point,
                                   grid: marsRover.grid,
                                   locations: [])
        } catch {
            print(error)
        }
    }
    
    override func tearDown() {
        marsRover = nil
        super.tearDown()
    }
    
    func test_should_recognise_if_invalid_command_in_string() throws {
        let expectedError = MarsRoverError.invalidCommand(command: "a", index: 2)
        var error: MarsRoverError!
        XCTAssertThrowsError(try marsRover.command(commands: "ffaff"), "a command does not exist") { thrownError in
            error = thrownError as? MarsRoverError
        }
        XCTAssertEqual(error, expectedError)
    }
    
    func test_turn() throws {
        XCTAssertEqual(marsRover.turn(turnTo: .forward, currentDirection: .S), .S, "should not turn if invalid command")
        XCTAssertEqual(marsRover.turn(turnTo: .turnLeft, currentDirection: .S), .E, "turn left from facing south")
        XCTAssertEqual(marsRover.turn(turnTo: .turnRight, currentDirection: .S), .W, "turn right from facing south is west")
        XCTAssertEqual(marsRover.turn(turnTo: .turnLeft, currentDirection: .W), .S)
        XCTAssertEqual(marsRover.turn(turnTo: .turnRight, currentDirection: .W), .N)
        
        XCTAssertEqual(marsRover.turn(turnTo: .turnLeft, currentDirection: .N), .W)
        XCTAssertEqual(marsRover.turn(turnTo: .turnRight, currentDirection: .N), .E)
        
        XCTAssertEqual(marsRover.turn(turnTo: .turnLeft, currentDirection: .E), .N)
        XCTAssertEqual(marsRover.turn(turnTo: .turnRight, currentDirection: .E), .S)
    }
    
    func test_wrap_within_grid() {
        XCTAssertEqual(marsRover.wrapWithinGrid(nextPoint: MarsRoverPoint(x: 10, y: 3), grid: (10, 10)),
                       MarsRoverPoint(x: 0, y: 3),
                       "should wrap around grid when going out of bounds")
        XCTAssertEqual(marsRover.wrapWithinGrid(nextPoint: MarsRoverPoint(x: -1, y: 3), grid: (10, 10)),
                       MarsRoverPoint(x: 9, y: 3),
                       "should wrap to end of grid if goind backwards")
        XCTAssertEqual(marsRover.wrapWithinGrid(nextPoint: MarsRoverPoint(x: 3, y: 10), grid: (10, 10)),
                       MarsRoverPoint(x: 3, y: 0),
                       "should wrap to start going over south bound")
        XCTAssertEqual(marsRover.wrapWithinGrid(nextPoint: MarsRoverPoint(x: 3, y: -1), grid: (10, 10)),
                       MarsRoverPoint(x: 3, y: 9),
                       "should wrap to end going over east bound")
    }
    
    func test_move() {
        let point = marsRover.move(move: .forward, point: MarsRoverPoint(x: 0, y: 0), direction: .S, grid: (10, 10))
        XCTAssertEqual(point, MarsRoverPoint(x: 0, y: 1), "should move one cell south")
        
        let point1 = marsRover.move(move: .backward, point: MarsRoverPoint(x: 0, y: 0), direction: .S, grid: (10, 10))
        XCTAssertEqual(point1, MarsRoverPoint(x: 0, y: 9), "should wrap around grid")
        
        let point2 = marsRover.move(move: .forward, point: MarsRoverPoint(x: 9, y: 0), direction: .E, grid: (10, 10))
        XCTAssertEqual(point2, MarsRoverPoint(x: 0, y: 0), "should wrap around latitude")
        
        let point3 = marsRover.move(move: .backward, point: MarsRoverPoint(x: 0, y: 0), direction: .E, grid: (10, 10))
        XCTAssertEqual(point3, MarsRoverPoint(x: 9, y: 0), "should wrap around latitude backwards")
    }
    
    func test_mars_rover_can_receive_commands() throws {
        marsRover = MarsRover(point: MarsRoverPoint(x: 0, y: 0), direction: .S, grid: (100, 100))
        try marsRover.command(commands: "fflff")
        
        let expectedPoint: MarsRoverPoint = MarsRoverPoint(x: 2, y: 2)
        XCTAssertEqual(marsRover.point, expectedPoint, "should start facing south, move s, s, turn left, move w , w, end in point x:2, y: 2")
        
        let expectedDirection: MarsRoverDirection = .E
        XCTAssertEqual(marsRover.direction, expectedDirection, "should be facing West")
    }
    
    func test_rover_should_detect_obstacles() throws {
        marsRover = MarsRover(point: MarsRoverPoint(x: 0, y: 0),
                              direction: .S,
                              grid: (10, 10))
        try marsRover.setObstacles(roverPosition: marsRover.point,
                               grid: marsRover.grid,
                               locations: [
                                MarsRoverPoint(x: 2, y: 2)
                               ])
        
        let expectedError = MarsRoverError.roverEncounteredObstacle(atPosition: MarsRoverPoint(x: 2, y: 2))
        var error: MarsRoverError!
        XCTAssertThrowsError(try marsRover.command(commands: "fflff")) { thrownError in
            error = thrownError as? MarsRoverError
        }
        XCTAssertEqual(error, expectedError, "rover encountered obstacle in position x: 2, y: 2")
        
        XCTAssertEqual(marsRover.point, MarsRoverPoint(x: 1, y: 2), "mars rover should moved till it encountered obstacle")
    }
    
    func test_rover_obstacle_position() throws {
        try marsRover.setObstacles(roverPosition: marsRover.point,
                               grid: marsRover.grid,
                               locations: [
                                MarsRoverPoint(x: 2, y: 2)
                               ])
        var obstaclePosition: MarsRoverPoint!
        do {
            try marsRover.command(commands: "ffrff")
        } catch MarsRoverError.roverEncounteredObstacle(let atPosition) {
            obstaclePosition = atPosition
        }
        
        XCTAssertEqual(obstaclePosition, MarsRoverPoint(x: 2, y: 2), "should be able to obtain position of encountered obstacle")
    }
}
