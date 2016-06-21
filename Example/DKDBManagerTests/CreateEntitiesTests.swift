//
//  CreateEntitiesTests.swift
//  DKDBManager
//
//  Created by kevin delord on 21/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import XCTest
import DKDBManager

// MARK: Common functions

extension DKDBTestCase {

	func createEntitiesFromJSON() {
		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")

		TestDataManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let json = TestDataManager.staticPlaneJSON(5)
			Plane.createEntitiesFromArray(json, inContext: savingContext)

		}) { (contextDidSave: Bool, error: NSError?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Plane.count(), 3, "the number of planes should be equals to 5")
			XCTAssertEqual(Plane.all()?.count, 3, "the number of planes should be equals to 5")
			expectation.fulfill()
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)
	}

 	func createDefaultEntities() {
		let json = TestDataManager.staticPlaneJSON(5)
		TestDataManager.saveWithBlockAndWait() { (savingContext: NSManagedObjectContext) -> Void in
			Plane.createEntitiesFromArray(json, inContext: savingContext)
		}
	}
}

class CreateEntitiesTestCase: DKDBTestCase {

}

extension CreateEntitiesTestCase {

	func testCreateEntityAndLaterSetValues() {

		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")

		TestDataManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let baggage = Baggage.createEntityInContext(savingContext)
			baggage?.weight = 65

		}) { (contextDidSave: Bool, error: NSError?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Baggage.count(), 1, "the number of baggages should be equals to 1")
			XCTAssertEqual(Baggage.all()?.count, 1, "the number of baggages should be equals to 1")

			let baggage = Baggage.MR_findFirst()
			XCTAssertNotNil(baggage)
			XCTAssertEqual(baggage?.weight, 65, "the baggage should weight 65")
			expectation.fulfill()
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)

	}

	func testUpdateFirstPlaneWithSameValues() {

		let json = TestDataManager.staticPlaneJSON(5)
		let onePlaneJson = (json.first ?? [:])

		TestDataManager.saveWithBlockAndWait() { (savingContext: NSManagedObjectContext) -> Void in
			Plane.createEntitiesFromArray([onePlaneJson], inContext: savingContext)
		}

		let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, "Paris", JSON.Destination, "London")
		let plane = Plane.MR_findFirstWithPredicate(predicate)

		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")
		TestDataManager.saveWithBlockAndWait() { (savingContext: NSManagedObjectContext) -> Void in

			Plane.createEntityFromDictionary(onePlaneJson, inContext: savingContext) { (entity, status) in
				XCTAssertEqual((entity as? Plane)?.objectID, plane?.objectID)
				print(onePlaneJson)
				print(status.rawValue)
				XCTAssertEqual(status, DKDBManagedObjectState.Save)
				expectation.fulfill()
			}
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)
	}

	func testUpdateFirstPlaneWithNewDestination() {

		self.createDefaultEntities()
		let newDestination = "Berlin"

		let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, "Paris", JSON.Destination, "London")
		let plane = Plane.MR_findFirstWithPredicate(predicate)

		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")

		TestDataManager.saveWithBlock() { (savingContext: NSManagedObjectContext) -> Void in
			plane?.entityInContext(savingContext)?.destination = newDestination
		}

		self.performBlockAfterDelay(1) {
			XCTAssertEqual(plane?.entityInDefaultContext()?.objectID, plane?.objectID, "Plane entities should have same object ID")
			XCTAssertEqual(plane?.entityInDefaultContext()?.destination, newDestination, "Plane destination should have been updated")
			expectation.fulfill()
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)
	}

}