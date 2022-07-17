//
//  MarsRover.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 16/07/2022.
//

import Foundation

struct MarsRover {
    private(set) var point: MarsRoverPoint
    private(set) var direction: MarsRoverDirection
    private(set) var grid: (latitude: Int, longitude: Int)
    private(set) var obstacles: [MarsRoverPoint] = []
    
    init(point: MarsRoverPoint, direction: MarsRoverDirection, grid: (latitude: Int, longitude: Int)) {
        self.point = point
        self.direction = direction
        self.grid = grid
        
        do {
            self.obstacles = try createObstacles(roverPosition: point, grid: grid, locations: nil)
        } catch {
            self.obstacles = []
        }
    }
    
    enum MarsRoverCommands: String {
        case forward = "f"
        case backward = "b"
        case turnLeft = "l"
        case turnRight = "r"
        
        static func isPresent(rawValue: String) -> Bool {
            MarsRoverCommands(rawValue: rawValue) != nil
        }
    }
    
    mutating func command(commands: String) throws -> Void {
        let commandArray: [MarsRoverCommands] = try mapCommandsStrToEnums(commands: commands)
        
        try commandArray.forEach { command in
            direction = turn(turnTo: command)
            let newPoint = move(move: command)
            if obstacles.contains(where: { $0.x == newPoint.x && $0.y == newPoint.y }) {
                throw MarsRoverError.roverEncounteredObstacle(atPosition: MarsRoverPoint(x: newPoint.x, y: newPoint.y))
            } else {
                point = newPoint
            }
        }
    }
    
    func mapCommandsStrToEnums(commands: String) throws -> [MarsRoverCommands] {
        var commandArray: [MarsRoverCommands] = []
        
        for (idx, commandChar) in commands.enumerated() {
            let command = String(commandChar)
            
            if MarsRoverCommands.isPresent(rawValue: command) == false {
                throw MarsRoverError.invalidCommand(command: command, index: idx)
            } else {
                commandArray.append(MarsRoverCommands(rawValue: command)!)
            }
        }
        
        return commandArray
    }
    
    func turn(turnTo: MarsRoverCommands,
              currentDirection currentDirectionOverrde: MarsRoverDirection? = nil) -> MarsRoverDirection {
            
            let direction = currentDirectionOverrde ?? self.direction
            
            if turnTo == .backward || turnTo == .forward {
                return direction
            }
            
            switch direction {
            case .S:
                return turnTo == .turnLeft ? .E : .W
            case .W:
                return turnTo == .turnLeft ? .S : .N
            case .N:
                return turnTo == .turnLeft ? .W : .E
            case .E:
                return turnTo == .turnLeft ? .N : .S
            }
    }
    
    func move(move: MarsRoverCommands,
              point pointOverride: MarsRoverPoint? = nil,
              direction directionOverride: MarsRoverDirection? = nil,
              grid gridOverride: (latitude: Int, longitude: Int)? = nil) -> MarsRoverPoint {
        
        let point = pointOverride ?? self.point
        let direction = directionOverride ?? self.direction
        let grid = gridOverride ?? self.grid
        
        if move == .turnRight || move == .turnLeft {
            return point
        }
        
        var newPoint: MarsRoverPoint
        
        switch direction {
        case .S:
            newPoint = move == .forward ? MarsRoverPoint(x: point.x, y: point.y + 1) : MarsRoverPoint(x: point.x, y: point.y - 1)
        case .W:
            newPoint = move == .forward ? MarsRoverPoint(x: point.x - 1, y: point.y) : MarsRoverPoint(x: point.x + 1, y: point.y)
        case .N:
            newPoint = move == .forward ? MarsRoverPoint(x: point.x, y: point.y - 1) : MarsRoverPoint(x: point.x, y: point.y + 1)
        case .E:
            newPoint = move == .forward ? MarsRoverPoint(x: point.x + 1, y: point.y) : MarsRoverPoint(x: point.x - 1, y: point.y)
        }
        
        return wrapWithinGrid(nextPoint: newPoint, grid: grid)
    }
    
    func wrapWithinGrid(nextPoint: MarsRoverPoint, grid: (latitude: Int, longitude: Int)) -> MarsRoverPoint {
        if nextPoint.x > (grid.latitude - 1) {
            return MarsRoverPoint(x: 0, y: nextPoint.y)
        } else if nextPoint.x < 0 {
            return MarsRoverPoint(x: grid.latitude - 1 , y: nextPoint.y)
        } else if nextPoint.y > (grid.longitude - 1) {
            return MarsRoverPoint(x: nextPoint.x, y: 0)
        } else if nextPoint.y < 0 {
            return MarsRoverPoint(x: nextPoint.x, y: grid.longitude - 1)
        } else {
            return nextPoint
        }
    }
    
    private func createObstacles(roverPosition: MarsRoverPoint,
                                 grid: (latitude: Int, longitude: Int),
                                 locations locationsOverride: [MarsRoverPoint]? = nil)throws -> [MarsRoverPoint] {
        
        let roverPosition = roverPosition
        let locations = locationsOverride ?? safelyGetRandomObstacles(roverPosition: roverPosition)
        
        func safelyGetRandomObstacles(roverPosition: MarsRoverPoint) -> [MarsRoverPoint] {
            if grid.latitude < 2 && grid.longitude < 2 {
                return [] as [MarsRoverPoint]
            } else {
                return Array(repeating: 0, count: 10).map { _ in
                    return generateRandomObstacles(roverPoint: roverPosition, grid: grid)
                }
            }
        }
        
        if locationsOverride != nil {
            try locationsOverride?.enumerated().forEach { (idx, location) in
                if location.x == roverPosition.x && location.y == roverPosition.y {
                    throw MarsRoverError.obstacleTryingToOverlapRoverPosition(location: location, index: idx)
                }
            }
        }
        
        return locations
    }
    
    private func generateRandomObstacles(roverPoint: MarsRoverPoint, grid: (latitude: Int, longitude: Int)) -> MarsRoverPoint {
        
        let x = Int.random(in: 0...grid.latitude)
        let y = Int.random(in: 0...grid.longitude)
        
        if x == roverPoint.x && y == roverPoint.y {
            return generateRandomObstacles(roverPoint: roverPoint, grid: grid)
        }
        
        return MarsRoverPoint(x: x, y: y)
    }
    
    mutating func setObstacles(roverPosition: MarsRoverPoint,
                               grid: (latitude: Int, longitude: Int),
                               locations locationsOverride: [MarsRoverPoint]? = nil) throws -> Void {
        
        obstacles = try createObstacles(roverPosition: roverPosition,
                                        grid: grid,
                                        locations: locationsOverride)
    }
}

struct MarsRoverPoint: Equatable {
    var x:Int
    var y: Int
}

enum MarsRoverDirection: String {
    case S = "SOUTH"
    case W = "WEST"
    case N = "NORTH"
    case E = "EAST"
    
    func canTurn(direction: MarsRoverDirection) -> Bool {
        switch self {
        case .S, .N:
            return direction == .W || direction == .E
        case .W, .E:
            return direction == .N || direction == .S
        }
    }
}

enum MarsRoverError:Error, Equatable {
    case invalidCommand(command: String, index: Int)
    case obstacleTryingToOverlapRoverPosition(location: MarsRoverPoint, index: Int)
    case roverEncounteredObstacle(atPosition: MarsRoverPoint)
    
    func getPosition() -> MarsRoverPoint? {
        switch self {
        case .roverEncounteredObstacle(let atPosition):
            return atPosition
        default:
            return nil
        }
    }
}


