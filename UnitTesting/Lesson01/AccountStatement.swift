//
//  AccountStatement.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 13/07/2022.
//

import Foundation

struct Account {
    private(set) var balance: Int = 0
    
    mutating func deposit(amount: Int) -> Void {
        print("\n\(amount)$ added to account")
        balance += amount
    }
    
    func withdraw(amount: Int) -> Void {
        print("\(amount) was withdrawn from account")
    }
    
    func printStatement() -> String {
        return "Your balance is \(balance)"
    }
}
