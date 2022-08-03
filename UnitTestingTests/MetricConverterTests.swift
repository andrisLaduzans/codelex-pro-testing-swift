//
//  MetricConverterTests.swift
//  UnitTestingTests
//
//  Created by Andris Laduzans on 03/08/2022.
//

import XCTest
@testable import UnitTesting

class MetricConverterTests: XCTestCase {
    var metricConverter: MetricConverter!
    
    override func setUp() {
        super.setUp()
        metricConverter = MetricConverter()
    }
    
    override func tearDown() {
        metricConverter = nil
        super.tearDown()
    }
    
    func test_convert_km_to_miles() {
        let miles = metricConverter.kilometersToMiles(1);
        XCTAssertEqual(miles, 0.621371, "should be albe to convert 1km to miles")
        XCTAssertEqual(metricConverter.kilometersToMiles(10), 6.21371, "should be able to convert 10 km to miles")
    }
    
    func test_celsius_to_fahrenheit() {
        XCTAssertEqual(metricConverter.celsiusToFahrenheit(C: 30), 86, "should be albe to convert Celsius to Fahrenheit")
    }
    
    func test_kg_to_pounds() {
        XCTAssertEqual(metricConverter.kgToPound(kg: 5), 11.02311311, "should be able to coonvert Kg to Pounds")
    }
}
