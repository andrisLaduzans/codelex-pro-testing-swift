//
//  AccountStatement.swift
//  UnitTestingTests
//
//  Created by Andris Laduzans on 13/07/2022.
//

import XCTest
@testable import UnitTesting

class AccountStatementTests: XCTestCase {

    var account: Account!
    
    override func setUp() {
        super.setUp()
        account = Account()
    }
    
    override func tearDown() {
        account = nil
        super.tearDown()
    }
    
    func test_can_deposit() throws {
        XCTAssertEqual(account.balance, 0, "initial balance should be 0")
        account.deposit(amount: 500)
        XCTAssertEqual(account.balance, 500, "balance should become 500 after depositing 500")
        account.deposit(amount: 10)
        XCTAssertEqual(account.balance, 510, "balance should become 510 after added 10 more")
    }
}
