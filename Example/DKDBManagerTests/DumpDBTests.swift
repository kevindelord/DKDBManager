//
//  DumpDBTests.swift
//  DKDBManager
//
//  Created by kevin delord on 21/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import XCTest
import DKDBManager

class DumpDBTest: DKDBTestCase {

	override func setUp() {
		super.setUp()

		let json = TestDataManager.staticPlaneJSON(5)
		TestDataManager.saveWithBlockAndWait() { (savingContext: NSManagedObjectContext) -> Void in
			Plane.createEntitiesFromArray(json, inContext: savingContext)
		}
	}
}

extension DumpDBTest {

	func testDumpCountWithVerbose() {
		TestDataManager.setVerbose(true)
		TestDataManager.dumpCount()
	}

	func testDumpCountWithoutVerbose() {
		TestDataManager.setVerbose(false)
		TestDataManager.dumpCount()
	}

	func testDumpWithVerbose() {
		TestDataManager.setVerbose(true)
		TestDataManager.dump()
	}

	func testDumpWithoutVerbose() {
		TestDataManager.setVerbose(false)
		TestDataManager.dump()
	}
}
