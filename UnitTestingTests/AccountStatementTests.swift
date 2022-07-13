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
    
    func test_can_withdraw() throws {
        account.deposit(amount: 500)
        try account.withdraw(amount: 100)
        XCTAssertEqual(account.balance, 400, "balance should be 400 after withdrawing 100 from 500")
    }
    
    func test_cannot_withtdraw_if_insufficient_balance() {
        account.deposit(amount: 400)
        let expectedError = AccountError.insufficientBalance(currentBalance: 400)
        var error: AccountError?
        
        XCTAssertThrowsError(try account.withdraw(amount: 500), "withdraw method should throw if withdrawable amount exceeds current balance") { thrownError in
            error = thrownError as? AccountError
        }
        
        XCTAssertEqual(expectedError, error)
    }
    
    func test_print_statement() throws {
        account.deposit(amount: 100, date: Date(timeIntervalSince1970: 1000))
        try account.withdraw(amount: 20, date: Date(timeIntervalSince1970: 1000))
        let history = account.printStatement()
        let expected = "Date           Amount    Balance   \n01/01/1970     +100      100       \n01/01/1970     -20       80        "
        XCTAssertEqual(history, expected, "print statement should print formatted account hisotory")
    }
    
    func test_print_tab() {
        let text = "Date"
        XCTAssertEqual(account.printTab(text, 10).count, 10, "print tab method should add whitespace to text till it reaches required length")
    }
}
