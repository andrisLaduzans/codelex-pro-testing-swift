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
    
    func litersToGalons(_ liters: Double, galonType: MetricConverterGalonType) -> Double {
        if galonType == .uk {
            return Double(String(format: "%.2f",(liters / 4.54609))) ?? 0
        } else {
            return Double(String(format: "%.2f", (liters / 3.785411784))) ?? 0
        }
    }
}

enum MetricConverterGalonType {
    case uk
    case us
}
