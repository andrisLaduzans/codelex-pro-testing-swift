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
        XCTAssertEqual(ohce.input("ohce Andris"), "¡Buenos días Andris!", "ohce should greet with user's name")
    }
}
