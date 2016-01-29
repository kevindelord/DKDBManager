//
//  DKDBManagerTest.swift
//  DKDBManager
//
//  Created by Panajotis Maroungas on 29/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import XCTest
import MagicalRecord

class DKDBManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
		MockManager.reset()

		super.tearDown()
    }
}

// MARK: - Testing DB Methods

// MARK: - Testing EntityClass

extension DKDBManagerTest {

	func testEntityClassNames() {

		// Set
		MockManager.addDemoEntityWithName("TestClass")
		MockManager.addDemoEntityWithName("TestClassA")
		MockManager.addDemoEntityWithName("TestClassB")

		// Call + Assert
		XCTAssertEqual(["TestClass","TestClassA","TestClassB"], MockManager.entityClassNames() as! [String])
	}
}

// MARK: - Testing Log Methods
// MARK: - Testing setVerbose

extension DKDBManagerTest {

	func testSetVerboseTrue() {

		// Set + Call
		MockManager.setVerbose(true)

		// Assert
		XCTAssertEqual(MockManager.loggingLevel(), MagicalRecord.loggingLevel())
	}

	func testSetVerboseFalse() {

		// Set + Call
		MockManager.setVerbose(false)

		// Assert
		XCTAssertEqual(MockManager.loggingLevel(), MagicalRecord.loggingLevel())
	}
}

// MARK: - Testing setupDatabaseWithName

extension DKDBManagerTest  {

	func testSetupDatabaseWithResetSucceed() {

		// Set
		MockManager.setResetStoredEntities(true)
		MockManager.allowsEraseDatabaseForName = true

		// Call
		MockManager.setupDatabaseWithName("TestDB") { () -> Void in
			// db reseted 
		}

		// Assert
		XCTAssertTrue(MockManager.didResetDatabaseBlockExecuted == true)
	}

	func testSetupDatabaseWithResetFailsDueWhenStoredEntitiesToFalse() {

		// Set
		MockManager.setResetStoredEntities(false)
		MockManager.allowsEraseDatabaseForName = true

		// Call
		MockManager.setupDatabaseWithName("TestDB") { () -> Void in
			// db reseted
		}

		// Assert
		XCTAssertTrue(MockManager.didResetDatabaseBlockExecuted == false)
	}

	func testSetupDatabaseWithResetFailsWhenTheDatabaseCannotBeDeleted() {

		// Set
		MockManager.setResetStoredEntities(true)
		MockManager.allowsEraseDatabaseForName = false

		// Call
		MockManager.setupDatabaseWithName("TestDB") { () -> Void in
			// db reseted
		}

		// Assert
		XCTAssertTrue(MockManager.didResetDatabaseBlockExecuted == false)
	}

	func testIfSetupDatabaseDidResetWasCalled() {
		// Set + Call
		MockManager.setupDatabaseWithName("TestDB")

		// Assert
		XCTAssertTrue(MockManager.setupDatabseDidResetCalled == true)
	}

}

// MARK: - Testing dumpCount

extension DKDBManagerTest {

	func testCalldumpCountWithVerbose() {

		// Set
		MockManager.setVerbose(true)

		// Call
		MockManager.dumpCount()

		// Assert
		XCTAssertTrue(MockManager.dumpCountInContextIsCalled == true)
	}

	func testCalldumpCountWithoutVerbose() {

		// Set
		MockManager.setVerbose(false)

		// Call
		MockManager.dumpCount()

		// Assert
		XCTAssertTrue(MockManager.dumpCountInContextIsCalled == false)
	}
}

// MARK: - Testing dump

extension DKDBManagerTest {

	func testCalldumpWithVerbose() {

		// Set
		MockManager.setVerbose(true)

		// Call
		MockManager.dump()

		// Assert
		XCTAssertTrue(MockManager.dumpInContextIsCalled == true)
	}

	func testCalldumpWithoutVerbose() {

		// Set
		MockManager.setVerbose(false)

		// Call
		MockManager.dumpCount()

		// Assert
		XCTAssertTrue(MockManager.dumpInContextIsCalled == false)
	}
}

// MARK: - MockManager subclass of DKDBManager

class MockManager : DKDBManager {

	// MARK: -  Static Properties of MockManager

	static var context							= NSManagedObjectContext()

	static var dumpCountInContextIsCalled 		= false
	static var dumpInContextIsCalled	 		= false

	static var allowsEraseDatabaseForName   	= false
	static var didResetDatabaseBlockExecuted 	= false

	static var setupDatabseDidResetCalled		= false

	static var demoEntities 					: [NSEntityDescription]?


	// MARK: - DB Methods

	override class func entityClassNames() -> [AnyObject] {

		var array 					= [AnyObject]()
		var entities 				= NSManagedObjectModel().entities

		if let _demoEntitiesNames = self.demoEntities {
			entities 				= _demoEntitiesNames
		}

		for desc in entities {
			array.append(desc.managedObjectClassName);
		}
		return array
	}

	override class func setupDatabaseWithName(databaseName: String, didResetDatabase: (() -> Void)?) {

		self.setupDatabseDidResetCalled = true

		var didResetDB = false
		if (DKDBManager.resetStoredEntities() == true) {
			didResetDB 				= self.eraseDatabaseForStoreName(databaseName)
		}

		if (didResetDB == true && didResetDatabase != nil) {
			self.didResetDatabaseBlockExecuted = true
		}
	}

	override class func eraseDatabaseForStoreName(databaseName: String) -> Bool {
		return self.allowsEraseDatabaseForName
	}

	// MARK: - Log Methods

	override class func dumpCount() {
		self.dumpCountInContext(self.context)
	}

	override class func dumpCountInContext(context: NSManagedObjectContext) {

		if (self.verbose() == false) {
			self.dumpCountInContextIsCalled = false
			return
		}

		self.dumpCountInContextIsCalled 	= true
	}


	override class func dump() {
		self.dumpInContext(self.context)
	}

	override class func dumpInContext(context: NSManagedObjectContext) {

		if (self.verbose() == false) {
			self.dumpInContextIsCalled 		= false
			return
		}
		self.dumpInContextIsCalled 			= true
	}

	// MARK: - Helpers

	class func addDemoEntityWithName(className: String) {

		if self.demoEntities == nil {
			self.demoEntities 				= [NSEntityDescription]()
		}

		let entity 							= NSEntityDescription()
		entity.managedObjectClassName 		= className
		self.demoEntities?.append(entity)
	}

	class func reset() {
		self.context						= NSManagedObjectContext()
		self.dumpCountInContextIsCalled 	= false
		self.dumpInContextIsCalled	 		= false
		self.allowsEraseDatabaseForName   	= false
		self.didResetDatabaseBlockExecuted 	= false
		self.setupDatabseDidResetCalled		= false
		self.demoEntities?.removeAll()
	}
}
