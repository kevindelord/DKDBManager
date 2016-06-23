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

// MARK: Setup functions without default setup

class LightSetupFunctionTest: DKDBTestCase {

	override func setupDatabase() {
		TestDataManager.setVerbose(true)
		// Optional: Reset the database on start to make this test app more understandable.
		TestDataManager.setResetStoredEntities(true)
		// Setup the database.
		TestDataManager.setup()
	}

	func testDidEraseDatabaseBlock() {
		// Optional: Reset the database on start to make this test app more understandable.
		TestDataManager.setResetStoredEntities(true)
		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")
		// Setup the database.
		TestDataManager.setupDatabaseWithName("testDB") {
			expectation.fulfill()
		}
		self.waitForExpectationsWithTimeout(5, handler: nil)
	}

	func testCreateValidDatabaseWithName() {
		TestDataManager.setResetStoredEntities(true)

		// Setup the database.
		TestDataManager.setupDatabaseWithName("testDB")

		self.createEntitiesFromJSON()
	}

	func testDefaultCoreDataStackInitialization() {
		DKDBManager.setup()
		XCTAssert(DKDBManager.entityClassNames().isEmpty == true, "Default setup should not find models in Unit Test bundle")
	}
}

// MARK: Setup functions with default setup

class SetupFunctionTest: DKDBTestCase {

	func testDatabaseManagerSetup() {

		let models = TestDataManager.entityClassNames()
		XCTAssertEqual(models.count, 3, "the number of models should be equals to 3: Plane, Passenger, Baggages")

		self.createEntitiesFromJSON()
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