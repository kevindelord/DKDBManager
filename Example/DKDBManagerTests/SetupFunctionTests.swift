//
//  SetupFunctionTests.swift
//  DKDBManager
//
//  Created by kevin delord on 20/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import XCTest
import DKDBManager

class SetupFunctionTest: XCTestCase {

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
		self.setupDatabase()
	}

	override func tearDown() {
		super.tearDown()
		TestDataManager.cleanUp()
	}

	func setupDatabase() {
		TestDataManager.setVerbose(true)
		// Optional: Reset the database on start to make this test app more understandable.
		TestDataManager.setResetStoredEntities(true)
		// Setup the database.
		TestDataManager.setup()
	}
}

// MARK: Setup functions

extension SetupFunctionTest {

	func testDatabaseManagerSetup() {

		let models = TestDataManager.entityClassNames()
		XCTAssertEqual(models.count, 3, "the number of models should be equals to 3: Plane, Passenger, Baggages")

		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")

		TestDataManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let json = TestDataManager.staticPlaneJSON(5)
			Plane.createEntitiesFromArray(json, inContext: savingContext)

		}) { (contextDidSave: Bool, error: NSError?) -> Void in
			// main thread
			XCTAssertEqual(Plane.count(), 3, "the number of planes should be equals to 5")
			expectation.fulfill()
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)
	}

	func testUpdateFirstPlaneWithSameValues() {

		let json = TestDataManager.staticPlaneJSON(5)
		let onePlaneJson = json.first

		TestDataManager.saveWithBlockAndWait() { (savingContext: NSManagedObjectContext) -> Void in
			Plane.createEntitiesFromArray(json, inContext: savingContext)
		}

		let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, "Paris", JSON.Destination, "London")
		let plane = Plane.MR_findFirstWithPredicate(predicate)


		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")
		TestDataManager.saveWithBlockAndWait() { (savingContext: NSManagedObjectContext) -> Void in
			Plane.createEntityFromDictionary(onePlaneJson, inContext: savingContext) { (entity, status) in
				XCTAssertEqual((entity as? Plane)?.objectID, plane?.objectID)
				XCTAssertEqual(status, DKDBManagedObjectState.Save)
				expectation.fulfill()
			}
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)

	}

	func testUpdateFirstPlaneWithNewDestination() {

		let json = TestDataManager.staticPlaneJSON(5)
		let newDestination = "Berlin"

		TestDataManager.saveWithBlockAndWait() { (savingContext: NSManagedObjectContext) -> Void in
			Plane.createEntitiesFromArray(json, inContext: savingContext)
		}

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

// MARK: Boolean state functions

extension SetupFunctionTest {

	func testBooleanStates() {

		for value in [false, true, false] {

			TestDataManager.setAllowUpdate(value)
			TestDataManager.setVerbose(value)
			TestDataManager.setResetStoredEntities(value)
			TestDataManager.setNeedForcedUpdate(value)

			XCTAssertEqual(TestDataManager.allowUpdate(), value, "the value of DKDBManager.allowUpdate should be equals to \(value)")
			XCTAssertEqual(TestDataManager.verbose(), value, "the value of DKDBManager.verbose should be equals to \(value)")
			XCTAssertEqual(TestDataManager.resetStoredEntities(), value, "the value of DKDBManager.resetStoredEntities should be equals to \(value)")
			XCTAssertEqual(TestDataManager.needForcedUpdate(), value, "the value of DKDBManager.needForcedUpdate should be equals to \(value)")
		}
	}
}