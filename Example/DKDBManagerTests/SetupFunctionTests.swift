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
	}

	override func tearDown() {
		super.tearDown()
	}
}

// MARK: Setup functions

extension SetupFunctionTest {

	func testDatabaseManagerSetup() {

		TestDataManager.setVerbose(true)
		// Optional: Reset the database on start to make this test app more understandable.
		TestDataManager.setResetStoredEntities(true)
		// Setup the database.
		TestDataManager.setup()

		let models = TestDataManager.entityClassNames()
		XCTAssertEqual(models.count, 3, "the number of models should be equals to 3: Plane, Passenger, Baggages")

		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")

		DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let json = TestDataManager.staticPlaneJSON(5)
			Plane.createEntitiesFromArray(json, inContext: savingContext)

		}) { (contextDidSave: Bool, error: NSError?) -> Void in
			// main thread
			XCTAssertEqual(Plane.count(), 5, "the number of planes should be equals to 5")
			expectation.fulfill()
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)
	}
}
