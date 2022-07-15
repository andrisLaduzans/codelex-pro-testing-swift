//
//  ChangeMaker.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 15/07/2022.
//
/*
 Change Maker
 You need to write the software to calculate the minimum number of coins required to return an amount of change to a user of Acme Vending machines. For example, the vending machine has coins 1,2,5 and 10 what is the minimum number of coins required to make up the change of 43 cents?

 The coin denominations will be supplied as a parameter. This is so the algorithm is not specific to one country. You may not hardcode these into the algorithm, they must be passed as a parameter.

 The country’s denominations to use for the kata are:

 British Pound
 1,2,5,10,20,50
 US Dollar
 1,5,10,25
 Norwegian Krone
 1,5,10,20
 The kata assumes an infinite number of coins of each denomination. You are to return an array with each coin to be given as change.

 Examples
 var coinDenominations = [1, 5, 10, 25]; // coin values converted to whole numbers
 var machine = new VendingMachine(coinDenominations);
 var purchaseAmount = 1.25; // amount the item cost
 var tenderAmount = 2.0; // amount the user input for the purchase
 var change = machine.CalculateChange(purchaseAmount, tenderAmount);
 // The expected result would be - (coin denominations as whole numbers)
 // change[0] = 25
 // change[1] = 25
 // change[2] = 25
 
 Bonus
 Remove the assumption that there are infinite coins of each denomination. Modify the code to accept a fixed number of each denomination. It will affect the change calculation in that you now need to consider the availability of coins when calculating change.
 */

import Foundation

struct ChangeMaker {
    private var coins: [ChangeMakerCoin]
    private var currentSum:Double {
        return coins.reduce(0.0) { sum, coins in
            return sum + coins.sum
        }
    }
    
    init(coinDenominations: ChangeMakerDenomination) {
        self.coins = coinDenominations.denominations().map() { value in
            ChangeMakerCoin(value: value, amount: 10)
        }.sorted { coinA, coinB in
            return coinA.value > coinB.value
        }
    }
    
    mutating func calculateChange(purchaseAmount: Double, tenderAmount: Double) throws -> [Int] {
        if let error = checkError(purchaseAmount: purchaseAmount, tenderAmount: tenderAmount) {
            throw error
        }
        
        let requiredSpare = try calculateSpareSum(purchaseAmout: purchaseAmount, tenderAmount: tenderAmount)
        var requiredOnes: Int = Int(requiredSpare * 100)
        
        var resultCoins: [Int] = []
        
        for (idx, coin) in coins.enumerated() {
            let (count, spare) = calcCountAndSpare(number: requiredOnes, modulo: coin.value)
            let coinArr = Array(repeating: coin.value, count: count)
            resultCoins += coinArr
            requiredOnes -= coin.value * count
            coins[idx].amount -= count
            
            if spare == 0 {
                break
            }
        }
        return resultCoins
    }
    
    func getCoinReport() -> [ChangeMakerCoin] {
        return coins
    }
    
    func calculateSpareSum(purchaseAmout: Double, tenderAmount: Double) throws -> Double {
        let spare = tenderAmount - purchaseAmout
        
        if spare < 0 {
            throw ChangeMakerError.insufficientTenderAmount(amountShort: spare * -1)
        }
        
        return tenderAmount - purchaseAmout
    }
    
    func getChangeSum() -> Double {
        return currentSum
    }
    
    func checkError(purchaseAmount: Double, tenderAmount: Double) -> ChangeMakerError? {
        let requiredChange = tenderAmount - purchaseAmount
        if requiredChange > currentSum {
            return ChangeMakerError.insufficientChangeInMachine(missingAmount: requiredChange - currentSum)
        }
        return nil
    }
    
    func calcCountAndSpare(number: Int, modulo: Int) -> (count: Int, spare: Int) {
        let quotient: Double = Double(number) / Double(modulo)
        
        if quotient < 1.0 {
            return (
                count: 0,
                spare: number
            )
        }
        
        let reminder: Int = number % modulo
        let roundDividend:Int =  number - reminder
        let roundQuotient: Int = Int(exactly: roundDividend / modulo)!
        
        return (
            count: roundQuotient,
            spare: reminder
        )
    }
}

enum ChangeMakerDenomination {
    case britishPound
    case usDollar
    case norwegianKrone
    
    func denominations() -> [Int] {
        switch self {
        case .britishPound:
            return [1, 2, 5, 10, 20, 50,]
        case .usDollar:
            return [1, 5, 10, 25]
        case .norwegianKrone:
            return [1, 5, 10, 20]
        }
    }
}

struct ChangeMakerCoin: Equatable {
    let value: Int
    var amount: Int
    init(value: Int, amount: Int) {
        self.value = value
        self.amount = amount
    }
    
    var sum: Double {
        let decimalValue:Double = Double(value) / 100
        return decimalValue * Double(amount)
    }
}

enum ChangeMakerError: Error, Equatable {
    case insufficientTenderAmount(amountShort: Double)
    case insufficientChangeInMachine(missingAmount: Double)
}
