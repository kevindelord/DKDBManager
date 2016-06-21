//
//  ValidateEntityTests.swift
//  DKDBManager
//
//  Created by kevin delord on 20/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import XCTest
import DKDBManager

class ValidateEntityTest: DKDBTestCase {

	override func setUp() {
		super.setUp()

		self.createDefaultEntities()
	}
}

extension ValidateEntityTest {

	func testCreatedEntityAsValid() {

		let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, "Paris", JSON.Destination, "London")
		let plane = Plane.MR_findFirstWithPredicate(predicate)

		XCTAssertEqual(plane?.deleted, false, "plane entity shoud be not be deleted")
		XCTAssertEqual(plane?.hasBeenDeleted, false, "plane entity shoud not have been deleted")
		XCTAssertEqual(plane?.doesExist, true, "plane entity shoud exist")
		XCTAssertEqual(plane?.hasValidContext, true, "plane entity shoud have valid context")
		XCTAssertNotEqual(plane?.doesExist, plane?.hasBeenDeleted)

		XCTAssertEqual(plane?.isValidInCurrentContext, true, "plane entity shoud be valid in context")
	}

	func testDeleteEntityState() {

		let plane = Plane.MR_findFirst()
		XCTAssertEqual(plane?.isValidInCurrentContext, true, "plane entity shoud be valid in context")

		// set expectation
		let expectation = self.expectationWithDescription("Wait for the Response")

		TestDataManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			Plane.deleteAllEntitiesInContext(savingContext)

		}) { (contextDidSave: Bool, error: NSError?) -> Void in
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(plane?.entityInDefaultContext()?.isValidInCurrentContext, false, "plane entity shoud be NOT valid in context")
			XCTAssertNotEqual(plane?.doesExist, plane?.hasBeenDeleted)
			expectation.fulfill()
		}

		self.waitForExpectationsWithTimeout(5, handler: nil)
	}
}