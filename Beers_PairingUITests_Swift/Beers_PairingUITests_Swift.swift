//
//  Beers_PairingUITests_Swift.swift
//  Beers_PairingUITests_Swift
//
//  Created by Alfredo Rinaudo on 21/07/2020.
//  Copyright © 2020 co.soprasteria. All rights reserved.
//

import XCTest

class Beers_PairingUITests_Swift: XCTestCase {
    
    let app = XCUIApplication()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFirstScreen() {
        let segmentedControls = app.segmentedControls
        XCTAssertEqual(segmentedControls.count, 1)
        
        let randomBeerButton = app.segmentedControls.buttons["Random beer"]
        XCTAssertTrue(randomBeerButton.isSelected)
        
        let scrollViews = app.scrollViews
        XCTAssertEqual(scrollViews.count, 2)
        
        let searchFields = app.searchFields
        XCTAssertEqual(searchFields.count, 1)
        
        let titleLabel = app.staticTexts["SopraSteria Beer Pairing"]
        XCTAssertTrue(titleLabel.exists)
    }
    
}
