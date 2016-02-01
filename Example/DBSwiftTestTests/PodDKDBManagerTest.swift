//
//  PodDKDBManagerTest.swift
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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testSetVerboseTrue() {

		// Set + Call
		MockedManager.setVerbose(true)

		// Assert
		XCTAssertEqual(MockedManager.loggingLevel(), MagicalRecord.loggingLevel())
	}

	func testSetVerboseFalse() {

		// Set + Call
		MockedManager.setVerbose(false)

		// Assert
		XCTAssertEqual(MockedManager.loggingLevel(), MagicalRecord.loggingLevel())
	}

	func testCalldumpCountWithVerbose() {

		// Set
		MockedManager.setVerbose(true)

		// Call
		MockedManager.dumpCount()

		// Assert
		XCTAssertTrue(MockedManager.dumpCountInContextIsCalled == true)
	}

	func testCalldumpCountWithoutVerbose() {

		// Set
		MockedManager.setVerbose(false)

		// Call
		MockedManager.dumpCount()

		// Assert
		XCTAssertTrue(MockedManager.dumpCountInContextIsCalled == false)
	}

	func testCalldumpWithVerbose() {

		// Set
		MockedManager.setVerbose(true)

		// Call
		MockedManager.dump()

		// Assert
		XCTAssertTrue(MockedManager.dumpInContextIsCalled == true)
	}

	func testCalldumpWithoutVerbose() {

		// Set
		MockedManager.setVerbose(false)

		// Call
		MockedManager.dumpCount()

		// Assert
		XCTAssertTrue(MockedManager.dumpInContextIsCalled == false)
	}

    func testEntityClassNames() {

		// Set
		MockedManager.addDemoEntityWithName("TestClass")
		MockedManager.addDemoEntityWithName("TestClassA")
		MockedManager.addDemoEntityWithName("TestClassB")

		// Call + Assert
		XCTAssertEqual(["TestClass","TestClassA","TestClassB"], MockedManager.entityClassNames() as! [String])
    }
    
}


// MARK: - Testing dumpCount

extension

// MARK: - DKDBManager Extension

class MockedManager : DKDBManager {

	// MARK: -  Static Properties

	static var context						= NSManagedObjectContext()
	static var dumpCountInContextIsCalled 	= false
	static var dumpInContextIsCalled	 	= false
	static var demoEntities 				: [NSEntityDescription]?

	// MARK: - Methods

	override class func entityClassNames() -> [AnyObject] {

		var array 		= [AnyObject]()
		var entities 	= NSManagedObjectModel().entities

		if let _demoEntitiesNames = self.demoEntities {
			entities = _demoEntitiesNames
		}

		for desc in entities {
			array.append(desc.managedObjectClassName);
		}
		return array
	}

	override class func dumpCount() {
		self.dumpCountInContext(self.context)
	}

	override class func dumpCountInContext(context: NSManagedObjectContext) {

		if (self.verbose() == false) {
			self.dumpCountInContextIsCalled = false
			return
		}

		self.dumpCountInContextIsCalled = true
	}


	override class func dump() {
		self.dumpInContext(self.context)
	}

	override class func dumpInContext(context: NSManagedObjectContext) {

		if (self.verbose() == false) {
			self.dumpInContextIsCalled = false
			return
		}
		self.dumpInContextIsCalled = true
	}

	class func addDemoEntityWithName(className: String) {
		if self.demoEntities == nil {
			self.demoEntities = [NSEntityDescription]()
		}
		let entity = NSEntityDescription()
		entity.managedObjectClassName = className

		self.demoEntities?.append(entity)
	}
}


