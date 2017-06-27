//
//  DeleteFunctionTests.swift
//  DKDBManager
//
//  Created by kevin delord on 20/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import XCTest
import DKDBManager

class DeleteFunctionTest: DKDBTestCase {

	override func setUp() {
		super.setUp()
		self.createDefaultEntities()
	}
}

// MARK: Delete functions

extension DeleteFunctionTest {

	func testShouldDeleteAllEntitiesInContext() {

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			TestDataManager.deleteAllEntities(in: savingContext)

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Plane.count(), 0, "the number of planes should be equals to 0")
			XCTAssertEqual(Plane.all()?.count, 0, "the number of planes should be equals to 0")

			XCTAssertEqual(Passenger.count(), 0, "the number of passengers should be equals to 0")
			XCTAssertEqual(Passenger.all()?.count, 0, "the number of passengers should be equals to 0")

			XCTAssertEqual(Baggage.count(), 0, "the number of baggages should be equals to 0")
			XCTAssertEqual(Baggage.all()?.count, 0, "the number of baggages should be equals to 0")

			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

	func testShouldDeleteAllPlanesAndSubEntities() {

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let planes = (Plane.mr_findAll(in: savingContext) as? [Plane] ?? [])
			for plane in planes {
				plane.deleteEntity(withReason: nil, in: savingContext)
			}

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Plane.count(), 0, "the number of planes should be equals to 0")
			XCTAssertEqual(Plane.all()?.count, 0, "the number of planes should be equals to 0")

			XCTAssertEqual(Passenger.count(), 0, "the number of passengers should be equals to 0")
			XCTAssertEqual(Passenger.all()?.count, 0, "the number of passengers should be equals to 0")

			XCTAssertEqual(Baggage.count(), 0, "the number of baggages should be equals to 0")
			XCTAssertEqual(Baggage.all()?.count, 0, "the number of baggages should be equals to 0")

			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

	func testShouldDeleteAllBaggagesButNotParentEntities() {

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let baggages = (Baggage.mr_findAll(in: savingContext) as? [Baggage] ?? [])
			for baggage in baggages {
				baggage.deleteEntity(withReason: nil, in: savingContext)
			}

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertNotEqual(Plane.count(), 0, "the number of planes should NOT be equals to 0")
			XCTAssertNotEqual(Plane.all()?.count, 0, "the number of planes should NOT be equals to 0")

			XCTAssertNotEqual(Passenger.count(), 0, "the number of passengers should NOT be equals to 0")
			XCTAssertNotEqual(Passenger.all()?.count, 0, "the number of passengers should NOT be equals to 0")

			XCTAssertEqual(Baggage.count(), 0, "the number of baggages should be equals to 0")
			XCTAssertEqual(Baggage.all()?.count, 0, "the number of baggages should be equals to 0")

			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

	func testShouldDeleteEntitiesForClassAndNotSubEntities() {

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			TestDataManager.deleteAllEntities(for: Plane.self, in: savingContext)

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Plane.count(), 0, "the number of planes should be equals to 0")
			XCTAssertEqual(Plane.all()?.count, 0, "the number of planes should be equals to 0")

			XCTAssertNotEqual(Passenger.count(), 0, "the number of passengers should NOT be equals to 0")
			XCTAssertNotEqual(Passenger.all()?.count, 0, "the number of passengers should NOT be equals to 0")

			XCTAssertNotEqual(Baggage.count(), 0, "the number of baggages should NOT be equals to 0")
			XCTAssertNotEqual(Baggage.all()?.count, 0, "the number of baggages should NOT be equals to 0")

			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}
}

