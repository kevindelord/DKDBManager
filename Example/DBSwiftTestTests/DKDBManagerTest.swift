//
//  DKDBManagerTest.swift
//  DKDBManager
//
//  Created by Panajotis Maroungas on 29/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import XCTest
import DKDBManager

class DKDBManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
		TestDataManager.reset()

		super.tearDown()
    }
}

// MARK: - Testing DB Methods

// MARK: - Testing EntityClass

extension DKDBManagerTest {

	func testEntityClassNames() {

		// Set
		TestDataManager.addDemoEntityWithName("TestClass")
		TestDataManager.addDemoEntityWithName("TestClassA")
		TestDataManager.addDemoEntityWithName("TestClassB")

		// Call + Assert
		XCTAssertEqual(["TestClass","TestClassA","TestClassB"], (TestDataManager.entityClassNames() as? [String]) ?? [])
	}
}

// MARK: - Testing CleanUp

extension DKDBManagerTest {

	func testCleanUpShouldDeleteStoredIdentifiers() {

		// Set + Call
		TestDataManager.cleanUp()

		// Assert
		XCTAssertTrue(TestDataManager.sharedInstance().storedIdentifiers.count == 0)
	}

}

// MARK: - Testing Log Methods

// MARK: - Testing setVerbose

extension DKDBManagerTest {

	func testSetVerboseTrue() {

		// Set + Call
		TestDataManager.setVerbose(true)

		// Assert
		XCTAssertEqual(TestDataManager.loggingLevel(), MagicalRecord.loggingLevel())
	}

	func testSetVerboseFalse() {

		// Set + Call
		TestDataManager.setVerbose(false)

		// Assert
		XCTAssertEqual(TestDataManager.loggingLevel(), MagicalRecord.loggingLevel())
	}
}

// MARK: - Testing setupDatabaseWithName

extension DKDBManagerTest  {

	func testSetupDatabaseWithResetSucceed() {

		// Set
		TestDataManager.setResetStoredEntities(true)
		TestDataManager.allowsEraseDatabaseForName = true

		// Call
		TestDataManager.setupDatabaseWithName("TestDB") { () -> Void in
			// db reseted 
		}

		// Assert
		XCTAssertTrue(TestDataManager.didResetDatabaseBlockExecuted == true)
	}

	func testSetupDatabaseWithResetFailsDueWhenStoredEntitiesToFalse() {

		// Set
		TestDataManager.setResetStoredEntities(false)
		TestDataManager.allowsEraseDatabaseForName = true

		// Call
		TestDataManager.setupDatabaseWithName("TestDB") { () -> Void in
			// db reseted
		}

		// Assert
		XCTAssertTrue(TestDataManager.didResetDatabaseBlockExecuted == false)
	}

	func testSetupDatabaseWithResetFailsWhenTheDatabaseCannotBeDeleted() {

		// Set
		TestDataManager.setResetStoredEntities(true)
		TestDataManager.allowsEraseDatabaseForName = false

		// Call
		TestDataManager.setupDatabaseWithName("TestDB") { () -> Void in
			// db reseted
		}

		// Assert
		XCTAssertTrue(TestDataManager.didResetDatabaseBlockExecuted == false)
	}

	func testIfSetupDatabaseDidResetWasCalled() {
		// Set + Call
		TestDataManager.setupDatabaseWithName("TestDB")

		// Assert
		XCTAssertTrue(TestDataManager.setupDatabaseDidResetCalled == true)
	}

}

// MARK: - Testing dumpCount

extension DKDBManagerTest {

	func testCallDumpCountWithVerbose() {

		// Set
		TestDataManager.setVerbose(true)

		// Call
		TestDataManager.dumpCount()

		// Assert
		XCTAssertTrue(TestDataManager.dumpCountInContextIsCalled == true)
	}

	func testCallDumpCountWithoutVerbose() {

		// Set
		TestDataManager.setVerbose(false)

		// Call
		TestDataManager.dumpCount()

		// Assert
		XCTAssertTrue(TestDataManager.dumpCountInContextIsCalled == false)
	}
}

// MARK: - Testing dump

extension DKDBManagerTest {

	func testCallDumpWithVerbose() {

		// Set
		TestDataManager.setVerbose(true)

		// Call
		TestDataManager.dump()

		// Assert
		XCTAssertTrue(TestDataManager.dumpInContextIsCalled == true)
	}

	func testCallDumpWithoutVerbose() {

		// Set
		TestDataManager.setVerbose(false)

		// Call
		TestDataManager.dumpCount()

		// Assert
		XCTAssertTrue(TestDataManager.dumpInContextIsCalled == false)
	}
}
