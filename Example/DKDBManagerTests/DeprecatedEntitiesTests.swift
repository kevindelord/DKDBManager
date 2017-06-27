//
//  DeprecatedEntitiesTests.swift
//  DKDBManager
//
//  Created by kevin delord on 21/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import XCTest
import DKDBManager

class DeprecatedEntitiesTest: DKDBTestCase {

	override func setUp() {
		super.setUp()

		self.createDefaultEntities()
	}
}

// MARK: Deprecated Entities functions

extension DeprecatedEntitiesTest {

	private func verifyDefaultUniqueIdentifiers() {
		var identifiers = TestDataManager.sharedInstance().storedIdentifiers
		XCTAssert(identifiers.allKeys.count == 3, "3 keys should be found. One per model")
		XCTAssertEqual((identifiers[NSStringFromClass(Plane.self)] as? [AnyObject])?.count, 4, "No entity identifier found for class: Plane")
		XCTAssertEqual((identifiers[NSStringFromClass(Passenger.self)] as? [AnyObject])?.count, 43, "No entity identifier found for class: Passenger")
		XCTAssertEqual((identifiers[NSStringFromClass(Baggage.self)] as? [AnyObject])?.count, 134, "No entity identifier found for class: Baggage")
	}

	/**
	Test: `removeAllStoredIdentifiers`
	*/
	func testShouldRemoveAllStoredIdentifiers() {

		XCTAssertNotEqual(Plane.count(), 0, "the number of planes should NOT be equals to 0")
		XCTAssertNotEqual(Passenger.count(), 0, "the number of passengers should NOT be equals to 0")
		XCTAssertNotEqual(Baggage.count(), 0, "the number of baggages should NOT be equals to 0")

		self.verifyDefaultUniqueIdentifiers()

		TestDataManager.removeAllStoredIdentifiers()

		let identifiers = TestDataManager.sharedInstance().storedIdentifiers
		XCTAssert(identifiers == [:], "storedIdentifiers should be empty")
		XCTAssert((identifiers[NSStringFromClass(Plane.self)] as? [AnyObject])?.count == nil, "Should not find entity identifier found for class: Plane")
		XCTAssert((identifiers[NSStringFromClass(Passenger.self)] as? [AnyObject])?.count == nil, "Should not find entity identifier found for class: Passenger")
		XCTAssert((identifiers[NSStringFromClass(Baggage.self)] as? [AnyObject])?.count == nil, "Should not find entity identifier found for class: Baggage")
	}

	/**
	Test: `removeAllStoredIdentifiersForClass:`
	*/
	func testShouldRemoveAllStoredIdentifiersForClass() {

		XCTAssertNotEqual(Plane.count(), 0, "the number of planes should NOT be equals to 0")
		XCTAssertNotEqual(Passenger.count(), 0, "the number of passengers should NOT be equals to 0")
		XCTAssertNotEqual(Baggage.count(), 0, "the number of baggages should NOT be equals to 0")

		self.verifyDefaultUniqueIdentifiers()

		TestDataManager.removeAllStoredIdentifiers(for: Passenger.self)

		let identifiers = TestDataManager.sharedInstance().storedIdentifiers
		XCTAssert(identifiers != [:], "storedIdentifiers should not be empty")
		XCTAssertEqual((identifiers[NSStringFromClass(Plane.self)] as? [AnyObject])?.count, 4, "Should find entity identifier found for class: Plane")
		XCTAssertNil(identifiers[NSStringFromClass(Passenger.self)] as? [AnyObject], "Should not find entity identifier found for class: Passenger")
		XCTAssertEqual((identifiers[NSStringFromClass(Baggage.self)] as? [AnyObject])?.count, 134, "Should find entity identifier found for class: Baggage")
	}

	/**
	Test: removeDeprecatedEntitiesInContext:
	*/
	func testShouldRemoveDeprecatedEntitiesForAllClass() {

		let planeCount = Plane.count()
		let passengerCount = Passenger.count()
		let baggageCount = Baggage.count()

		let deleteNumber = 2
		var json = TestDataManager.staticPlaneJSON()
		json.removeFirst(deleteNumber)
		TestDataManager.save(blockAndWait: { (savingContext: NSManagedObjectContext) -> Void in
			Plane.crudEntities(with: json, in: savingContext)
			TestDataManager.removeDeprecatedEntities(in: savingContext)
		})

		XCTAssertEqual(Plane.count(), planeCount - deleteNumber)
		XCTAssertEqual(Passenger.count(), passengerCount - (deleteNumber * 5))
		XCTAssert(Baggage.count() < baggageCount)
	}

	/**
	Test: removeDeprecatedEntitiesInContext:forClass:
	*/
	func testShouldRemoveDeprecatedEntitiesForOneClass() {

		let planeCount = Plane.count()
		let passengerCount = Passenger.count()
		let baggageCount = Baggage.count()

		let deleteNumber = 2
		var json = TestDataManager.staticPlaneJSON()
		json.removeFirst(deleteNumber)
		TestDataManager.save(blockAndWait: { (savingContext: NSManagedObjectContext) -> Void in
			Plane.crudEntities(with: json, in: savingContext)
			TestDataManager.removeDeprecatedEntities(in: savingContext, for: Baggage.self)
		})

		XCTAssertEqual(Plane.count(), planeCount)
		XCTAssertEqual(Passenger.count(), passengerCount)
		XCTAssert(Baggage.count() < baggageCount)
	}
}
