//
//  MetricConverter.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 03/08/2022.
//

import Foundation

struct MetricConverter {
    func kilometersToMiles(_ units: Int) -> Double {
        return 0.621371 * Double(units)
    }
    
    func celsiusToFahrenheit(C celsius: Int) -> Double {
        return Double(celsius) * 1.8 + 32
    }
    
    func kgToPound(kg: Double) -> Double {
        let res = kg / 0.45359237
        let formatted = String(format: "%.8f", res)
        return Double(formatted)!
    }
}
