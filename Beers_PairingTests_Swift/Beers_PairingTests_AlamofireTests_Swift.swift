//
//  Beers_PairingTests_Swift.swift
//  Beers_PairingTests_Swift
//
//  Created by Alfredo Rinaudo on 17/07/2020.
//  Copyright © 2020 co.soprasteria. All rights reserved.
//

import Alamofire
//import Foundation
import XCTest
@testable import Beers_Pairing

class Beers_PairingTests_AlamofireTests_Swift: XCTestCase {
    
    var sut: ApiClient!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = ApiClient()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }
    
    func testGetMeRandomBeerResponseOneObject2ndMethod() {
        // Given
        let promise = expectation(description: "Get only one beer")
        
        // When
        self.sut.getMeRandomBeer { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                // Then
                XCTAssertNotNil(beers, "Expected non-nil object")
                XCTAssertEqual(beers?.count, 1, "Must return only one item")
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: TimeInterval(5)) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testGetAllBeersStartingAtPage0() {
        // Given
        let promise = expectation(description: "Get only one beer")
        // When
        self.sut.getAllBeers(byFood: "", fromPage: 0, perPage: 20) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                // Then
                XCTAssertNil(beers, "Expected non-nil object")
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: TimeInterval(5)) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testGetAllBeersStartingAtPage1() {
        // Given
        let promise = expectation(description: "Get only one beer")
        // When
        sut.getAllBeers(byFood: "", fromPage: 1, perPage: 20) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                // Then
                XCTAssertNotNil(beers, "Expected non-nil object")
                if let beers = beers {
                    XCTAssertLessThanOrEqual(beers.count, 20, "Must return 10 or less items")
                }
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: TimeInterval(5)) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testGetAllBeersStartingAtPage1PairingCheese() {
        // Given
        let promise = expectation(description: "Get only one beer")
        // When
        sut.getAllBeers(byFood: "Cheese", fromPage: 1, perPage: 20) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                // Then
                XCTAssertNotNil(beers, "Expected non-nil object")
                if let beers = beers {
                    XCTAssertLessThanOrEqual(beers.count, 20, "Must return 20 or less items")
                }
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: TimeInterval(5)) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testGetBeerDetails() {
        // Given
        let promise = expectation(description: "Get only one beer")
        // When
        sut.getBeerDetails(beerId: 288) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                // Then
                XCTAssertNotNil(beers, "Expected non-nil object")
                XCTAssertEqual(beers?.count, 1, "Must return only one item")
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: TimeInterval(5)) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testFailGetBeerDetails() {
        // Given
        let promise = expectation(description: "Get only one beer")
        // When
        sut.getBeerDetails(beerId: 0) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                // Then
                XCTAssertNil(beers, "Expected nil object")
                XCTAssertNotNil(error)
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: TimeInterval(5)) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
}
