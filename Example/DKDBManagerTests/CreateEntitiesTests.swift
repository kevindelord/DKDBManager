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
		let expectation = self.expectation(description: "Wait for the Response")

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let json = TestDataManager.staticPlaneJSON()
			Plane.crudEntities(with: json, in: savingContext)

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Plane.count(), 4, "the number of planes should be equals to 5")
			XCTAssertEqual(Plane.all()?.count, 4, "the number of planes should be equals to 5")
			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

 	func createDefaultEntities() {
		let json = TestDataManager.staticPlaneJSON()
		TestDataManager.save(blockAndWait: { (savingContext: NSManagedObjectContext) -> Void in
			Plane.crudEntities(with: json, in: savingContext)
		})
	}
}

class CreateEntitiesTestCase: DKDBTestCase {

}

extension CreateEntitiesTestCase {

	func testCreateEntityWithDictionary() {

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")
		let weight = 254

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread

			let baggage = Baggage.crudEntity(with: ["weight":weight], in: savingContext)
			XCTAssertEqual(baggage?.weight?.intValue, weight, "Baggage's weight must be equals")

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Baggage.count(), 1, "the number of baggages should be equals to 1")
			XCTAssertEqual(Baggage.all()?.count, 1, "the number of baggages should be equals to 1")

			let baggage = Baggage.mr_findFirst()
			XCTAssertNotNil(baggage)
			XCTAssertEqual(baggage?.weight?.intValue, weight, "the baggage should weight \(weight)")
			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

	func testCreateEntityAndLaterSetValues() {

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			let baggage = Baggage.crudEntity(in: savingContext)
			baggage?.weight = 65

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			XCTAssertTrue(contextDidSave)
			XCTAssertNil(error)

			XCTAssertEqual(Baggage.count(), 1, "the number of baggages should be equals to 1")
			XCTAssertEqual(Baggage.all()?.count, 1, "the number of baggages should be equals to 1")

			let baggage = Baggage.mr_findFirst()
			XCTAssertNotNil(baggage)
			XCTAssertEqual(baggage?.weight, 65, "the baggage should weight 65")
			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

	func testUpdateFirstPlaneWithSameValues() {

		let json = TestDataManager.staticPlaneJSON()
		let onePlaneJson = (json.first ?? [:])

		TestDataManager.save(blockAndWait: { (savingContext: NSManagedObjectContext) -> Void in
			Plane.crudEntities(with: [onePlaneJson], in: savingContext)
		})

		let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, "Paris", JSON.Destination, "London")
		let plane = Plane.mr_findFirst(with: predicate)

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")
		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in

			Plane.crudEntity(with: onePlaneJson, in: savingContext) { (entity, status) in
				XCTAssertEqual((entity as? Plane)?.objectID, plane?.objectID)
				print(onePlaneJson)
				print(status.rawValue)
				XCTAssertEqual(status, DKDBManagedObjectState.save)
				expectation.fulfill()
			}
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

	func testUpdateFirstPlaneWithNewDestination() {

		self.createDefaultEntities()
		let newDestination = "Berlin"

		let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, "Paris", JSON.Destination, "London")
		let plane = Plane.mr_findFirst(with: predicate)

		// set expectation
		let expectation = self.expectation(description: "Wait for the Response")

		TestDataManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			plane?.entity(in: savingContext)?.destination = newDestination

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in

			XCTAssertTrue(contextDidSave)
			XCTAssertEqual(plane?.entityInDefaultContext()?.objectID, plane?.objectID, "Plane entities should have same object ID")
			XCTAssertEqual(plane?.entityInDefaultContext()?.destination, newDestination, "Plane destination should have been updated")
			expectation.fulfill()
		})

		self.waitForExpectations(timeout: 5, handler: nil)
	}

}
