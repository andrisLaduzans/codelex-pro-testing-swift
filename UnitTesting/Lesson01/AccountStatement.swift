//
//  AccountStatement.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 13/07/2022.
//

import Foundation

struct Account {
    private(set) var balance: Int = 0
    private(set) var history: [AccountHistoryItem] = []
    
    mutating func deposit(amount: Int, date: Date = Date.now) -> Void {
        print("\n\(amount)$ added to account")
        balance += amount
        addHistory(amount: amount, transaction: .deposit, date: date)
    }
    
    mutating func withdraw(amount: Int, date: Date = Date.now) throws -> Void {
        print("\n\(amount) was withdrawn from account")
        if balance - amount < 0 {
            throw AccountError.insufficientBalance(currentBalance: balance)
        } else {
            balance -= amount
            addHistory(amount: amount, transaction: .withdraw, date: date)
        }
    }
    
    func printStatement() -> String {
        let parsedHistory: String = history.reduce("\(printTab("Date", 15))\(printTab("Amount"))\(printTab("Balance"))") { acc, curr in
            
            return acc + "\n\(printTab(formatDate(date:curr.date), 15))\(printTab(curr.transactionAmount))\(printTab(String(curr.balance)))"
        }
        
        print("\n\(parsedHistory)")
        return parsedHistory
    }
    
    private mutating func addHistory(amount: Int, transaction: Transaction, date: Date) -> Void {
        history.append(AccountHistoryItem(date: date, transactionAmount: "\(transaction.rawValue)\(amount)", balance: balance))
    }
    
    private enum Transaction: Character {
        case deposit = "+"
        case withdraw = "-"
    }
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM.yyyy")
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func printTab(_ text: String, _ length: Int = 10) -> String {
        var result = text
        for _ in 0..<(length - text.count) {
            result += " "
        }
        return result
    }
}

struct AccountHistoryItem {
    let date: Date
    let transactionAmount: String
    let balance: Int
}

enum AccountError: Error, Equatable {
    case insufficientBalance(currentBalance: Int)
}
