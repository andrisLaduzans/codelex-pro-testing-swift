//
//  OhceTests.swift
//  UnitTestingTests
//
//  Created by Andris Laduzans on 04/08/2022.
//

import XCTest
@testable import UnitTesting

class OhceTests: XCTestCase {
    var ohce: Ohce!
    
    override func setUp() {
        super.setUp()
        ohce = Ohce()
    }
    
    override func tearDown() {
        ohce = nil
        super.tearDown()
    }
    
    func test_ohce_can_greet(){
        var response = ohce.input("ohce Andris");
        XCTAssertEqual(response, "¡Buenos días Andris!", "ohce should greet with user's name")
        response = ohce.input("ohce Lala");
        XCTAssertEqual(response, "¡Buenos días Lala!")
    }
}
