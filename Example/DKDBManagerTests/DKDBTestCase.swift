//
//  DKDBTestCase.swift
//  DKDBManager
//
//  Created by kevin delord on 20/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import XCTest
import DKDBManager

class DKDBTestCase: XCTestCase {

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