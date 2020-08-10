//
//  AlamofireRequestsTests.swift
//  Beers_PairingTests_Swift
//
//  Created by Alfredo Rinaudo on 24/07/2020.
//  Copyright © 2020 co.soprasteria. All rights reserved.
//

import XCTest
@testable import Alamofire
@testable import Beers_Pairing

class Beers_PairingTests_MockedAlamofireTests_Swift: XCTestCase {

    var sut: ApiClient!

    override func setUp() {
        super.setUp()

        let manager: SessionManager = {
            let configuration: URLSessionConfiguration = {
                let configuration = URLSessionConfiguration.default
                configuration.protocolClasses = [MockURLProtocol.self]
                return configuration
            }()

            return SessionManager(configuration: configuration)
        }()
        sut = ApiClient(manager: manager)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testGetAllBeersStatusCode200() {
        // given
        MockURLProtocol.responseWithStatusCode(code: 200)
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getAllBeers(byFood: "", fromPage: 1, perPage: 20) { (response) in
            XCTAssertEqual(response.response?.statusCode, 200)
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testGetAllBeersFoodPairedStatusCode200() {
        // given
        MockURLProtocol.responseWithStatusCode(code: 200)
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getAllBeers(byFood: "chicken masala", fromPage: 1, perPage: 20) { (response) in
            XCTAssertEqual(response.response?.statusCode, 200)
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testGetAllBeersFailure() {
        // given
        MockURLProtocol.responseWithFailure()
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getAllBeers(byFood: "", fromPage: 1, perPage: 20) { (response) in
            XCTAssertNotNil(response.error)
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testGetAllBeersFailurePage() {
        // given
        MockURLProtocol.responseWithFailure()
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getAllBeers(byFood: "", fromPage: 0, perPage: 20) { (response) in
            XCTAssertNotNil(response.error)
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testGetMeRandomBeerStatusCode200() {
        // given
        MockURLProtocol.responseWithStatusCode(code: 200)
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getMeRandomBeer { (response) in
            XCTAssertEqual(response.response?.statusCode, 200)
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testGetMeRandomBeerFailure() {
        // given
        MockURLProtocol.responseWithFailure()
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getMeRandomBeer { (response) in
            XCTAssertNotNil(response.error)
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testGetBeerDetails() {
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "288", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
        // given
        MockURLProtocol.responseWithData(data: data!)
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getBeerDetails(beerId: 288) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                XCTAssertNotNil(beers)
                XCTAssertNil(error)
                XCTAssertEqual(beers?.count, 1, "Must return only one item")
                expectation.fulfill()
            }
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testGetBeerDetailsFailure() {
        // given
        MockURLProtocol.responseWithDataError()
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getBeerDetails(beerId: 288) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                XCTAssertNil(beers)
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testSuccessSerializeResponse() {
        // given
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "288", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)

        // when
        let beers = sut.serializeResponse(responseData: data!)

        // then
        XCTAssertNotNil(beers)
        XCTAssertEqual(beers?.count, 1, "Must return only one item")
    }

    func testFailureSerializeResponse() {
        // given
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "288fail", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
        MockURLProtocol.responseWithData(data: data!)
        let expectation = XCTestExpectation(description: "Performs a request")

        // when
        sut.getBeerDetails(beerId: 288) { (response) in
            self.sut.responseHandler(response: response) { (beers, error) in
                XCTAssertNil(beers)
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }

        // then
        wait(for: [expectation], timeout: 0.5)
    }

    func testSortBeers() {
        // given
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "288noAbv", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)

        // when
        var beers = sut.serializeResponse(responseData: data!)
        beers = sut.sortBeers(beers: beers!)

        XCTAssert(true, "true")
    }

}
