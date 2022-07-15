//
//  ChangeMakerTests.swift
//  UnitTestingTests
//
//  Created by Andris Laduzans on 15/07/2022.
//

import XCTest
@testable import UnitTesting

class ChangeMakerTests: XCTestCase {
    var changeMaker: ChangeMaker!
    
    override func setUp() {
        super.setUp()
        changeMaker = ChangeMaker(coinDenominations: .britishPound)
    }
    
    override func tearDown() {
        changeMaker = nil
        super.tearDown()
    }
    
    func test_can_calculate_spare_sum() throws {
        let spare = try changeMaker.calculateSpareSum(purchaseAmout: 1.25, tenderAmount: 2.0)
        XCTAssertEqual(spare, 0.75, "should return spare amount")
    }
    
    func test_tender_amount_too_little() throws {
        let expectedError = ChangeMakerError.insufficientTenderAmount(amountShort: 0.25)
        var error: ChangeMakerError!
        
        XCTAssertThrowsError(try changeMaker.calculateSpareSum(purchaseAmout: 2.0, tenderAmount: 1.75)) { thrownError in
            error = thrownError as? ChangeMakerError
        }
        XCTAssertEqual(error, expectedError, "should throw error, when user wants to pay less than required")
    }
    
    func test_coin_sum() {
        let sum = ChangeMakerCoin(value: 25, amount: 2).sum
        XCTAssertEqual(sum, 0.5, "should be able to calculate of current sum of coins")
    }
    
    func test_error_if_isufficient_coins_in_machine() throws {
        var changeMaker = ChangeMaker(coinDenominations: .usDollar)
        let sum = changeMaker.getChangeSum()
        /* us dollar denominations [1, 5, 10, 25]
         1 * 10 = 10
         5 * 10 = 50
         10 * 10 = 100
         25 * 10 = 250
         total: 410
         410 / 100 = 4.1
         */
        XCTAssertEqual(sum, 4.1, "should be able to calculate how much change is in machine initially")
        
        let expectedError = ChangeMakerError.insufficientChangeInMachine(missingAmount: 5.9)
        var error: ChangeMakerError!
        XCTAssertThrowsError(try changeMaker.calculateChange(purchaseAmount: 0.0, tenderAmount: 10.0)) { thrownError in
            error = thrownError as? ChangeMakerError
        }
        XCTAssertEqual(error, expectedError, "should notice if machine has insufficient change to return")
    }
    
    func test_calc_count_and_spare_of_modulo() {
        var (count, spare) = changeMaker.calcCountAndSpare(number: 2, modulo: 3)
        XCTAssertEqual(count, 0)
        XCTAssertEqual(spare, 2)
        
        (count, spare) = changeMaker.calcCountAndSpare(number: 200, modulo: 79)
        XCTAssertEqual(count, 2)
        XCTAssertEqual(spare, 42)
        
        (count, spare) = changeMaker.calcCountAndSpare(number: 2, modulo: 2)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(spare, 0)
    }
    
    func test_calculate_change_usd() throws {
        //denominations: [1, 5, 10, 25]
        var changeMaker = ChangeMaker(coinDenominations: .usDollar)
        let change: [Int] = try changeMaker.calculateChange(purchaseAmount: 1.33, tenderAmount: 2.0)
        let expectedChange = [25, 25, 10, 5, 1, 1]
        XCTAssertEqual(change, expectedChange, "should calculate coins")
        
        let coinsInMachine = changeMaker.getCoinReport()
        let expectedCoinsInMachine: [ChangeMakerCoin] = [
            ChangeMakerCoin(value: 25, amount: 8),
            ChangeMakerCoin(value: 10, amount: 9),
            ChangeMakerCoin(value: 5, amount: 9),
            ChangeMakerCoin(value: 1, amount: 8),
        ]
        XCTAssertEqual(coinsInMachine, expectedCoinsInMachine, "should reduce change amount after transaction")
    }
    
    func test_calculate_change_british_pound() throws {
        //denominations: [1, 2, 5, 10, 20, 50,]
        var changeMaker = ChangeMaker(coinDenominations: .britishPound)
        let change: [Int] = try changeMaker.calculateChange(purchaseAmount: 0.61, tenderAmount: 2.0)
        let expectedChange = [50, 50, 20, 10, 5, 2, 2]
        XCTAssertEqual(change, expectedChange, "should calculate coins")

        let coinsInMachine = changeMaker.getCoinReport()
        let expectedCoinsInMachine: [ChangeMakerCoin] = [
            ChangeMakerCoin(value: 50, amount: 8),
            ChangeMakerCoin(value: 20, amount: 9),
            ChangeMakerCoin(value: 10, amount: 9),
            ChangeMakerCoin(value: 5, amount: 9),
            ChangeMakerCoin(value: 2, amount: 8),
            ChangeMakerCoin(value: 1, amount: 10)
        ]
        XCTAssertEqual(coinsInMachine, expectedCoinsInMachine, "should reduce change amount after transaction")
    }
    
    func test_calculate_change_norwegian_krone() throws {
        //denominations: [1, 5, 10, 20]
        var changeMaker = ChangeMaker(coinDenominations: .norwegianKrone)
        let change: [Int] = try changeMaker.calculateChange(purchaseAmount: 1.97, tenderAmount: 2.0)
        let expectedChange = [1, 1, 1]
        XCTAssertEqual(change, expectedChange, "should calculate coins")
        
        let coinsInMachine = changeMaker.getCoinReport()
        print("coinsInMachine: \(coinsInMachine)")
        let expectedCoinsInMachine: [ChangeMakerCoin] = [
            ChangeMakerCoin(value: 20, amount: 10),
            ChangeMakerCoin(value: 10, amount: 10),
            ChangeMakerCoin(value: 5, amount: 10),
            ChangeMakerCoin(value: 1, amount: 7)
        ]
        XCTAssertEqual(coinsInMachine, expectedCoinsInMachine, "should reduce change amount after transaction")
    }
    
    //TODO: test cases when some of the coins have run out
    //TODO: test cases when total sum of change in machine is sufficient, but small value coins have run out, and exact return of change is impossible
}
