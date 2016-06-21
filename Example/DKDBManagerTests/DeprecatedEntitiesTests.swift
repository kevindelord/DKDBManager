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

// Functions to test:
// removeDeprecatedEntitiesInContext:forClass:
// removeDeprecatedEntitiesInContext:
// removeDeprecatedEntitiesFromArray:

class DeprecatedEntitiesTest: DKDBTestCase {

	override func setUp() {
		super.setUp()
		self.createDefaultEntities()
	}
}

// MARK: Deprecated Entities functions

extension DeprecatedEntitiesTest {

	/**
	Test: `removeAllStoredIdentifiers`
	*/
	func testShouldRemoveAllStoredIdentifiers() {

		XCTAssertNotEqual(Plane.count(), 0, "the number of planes should NOT be equals to 0")
		XCTAssertNotEqual(Passenger.count(), 0, "the number of passengers should NOT be equals to 0")
		XCTAssertNotEqual(Baggage.count(), 0, "the number of baggages should NOT be equals to 0")

		var identifiers = TestDataManager.sharedInstance().storedIdentifiers
		XCTAssert(identifiers.allKeys.count == 3, "3 keys should be found. One per model")
		XCTAssert(identifiers[NSStringFromClass(Plane)]?.count > 0, "No entity identifier found for class: Plane")
		XCTAssert(identifiers[NSStringFromClass(Baggage)]?.count > 0, "No entity identifier found for class: Baggage")
		XCTAssert(identifiers[NSStringFromClass(Passenger)]?.count > 0, "No entity identifier found for class: Passenger")

		TestDataManager.removeAllStoredIdentifiers()

		identifiers = TestDataManager.sharedInstance().storedIdentifiers
		XCTAssert(identifiers == [:], "storedIdentifiers should be empty")
		XCTAssert((identifiers[NSStringFromClass(Plane)] as? [AnyObject])?.count == nil, "Should not find entity identifier found for class: Plane")
		XCTAssert((identifiers[NSStringFromClass(Baggage)] as? [AnyObject])?.count == nil, "Should not find entity identifier found for class: Baggage")
		XCTAssert((identifiers[NSStringFromClass(Passenger)] as? [AnyObject])?.count == nil, "Should not find entity identifier found for class: Passenger")
	}

	/**
	Test: `removeAllStoredIdentifiersForClass:`
	*/
	func testShouldRemoveAllStoredIdentifiersForClass() {

		XCTAssertNotEqual(Plane.count(), 0, "the number of planes should NOT be equals to 0")
		XCTAssertNotEqual(Passenger.count(), 0, "the number of passengers should NOT be equals to 0")
		XCTAssertNotEqual(Baggage.count(), 0, "the number of baggages should NOT be equals to 0")

		var identifiers = TestDataManager.sharedInstance().storedIdentifiers

		XCTAssert(identifiers.allKeys.count == 3, "3 keys should be found. One per model")

		XCTAssert(identifiers[NSStringFromClass(Plane)]?.count > 0, "No entity identifier found for class: Plane")
		XCTAssert(identifiers[NSStringFromClass(Baggage)]?.count > 0, "No entity identifier found for class: Baggage")
		XCTAssert(identifiers[NSStringFromClass(Passenger)]?.count > 0, "No entity identifier found for class: Passenger")

		TestDataManager.removeAllStoredIdentifiersForClass(Passenger)

		identifiers = TestDataManager.sharedInstance().storedIdentifiers
		XCTAssert(identifiers != [:], "storedIdentifiers should not be empty")
		XCTAssert(identifiers[NSStringFromClass(Plane)]?.count > 0, "Should find entity identifier found for class: Plane")
		XCTAssert(identifiers[NSStringFromClass(Baggage)]?.count > 0, "Should find entity identifier found for class: Baggage")
		XCTAssert((identifiers[NSStringFromClass(Passenger)] as? [AnyObject])?.count == nil, "Should not find entity identifier found for class: Passenger")
	}


}