//
//  TestDataManager.swift
//  DKDBManager
//
//  Created by kevin delord on 20/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import DKDBManager

// MARK: - MockManager subclass of DKDBManager

class TestDataManager : DKDBManager {

	// MARK: -  Static Properties of MockManager

	static var context							= NSManagedObjectContext()

	static var dumpCountInContextIsCalled 		= false
	static var dumpInContextIsCalled	 		= false

	static var allowsEraseDatabaseForName   	= false
	static var didResetDatabaseBlockExecuted 	= false

	static var setupDatabaseDidResetCalled		= false

	static var demoEntities 					: [NSEntityDescription]?


	// MARK: - DB Methods

	override class func entityClassNames() -> [AnyObject] {

		var array 					= [AnyObject]()
		var entities 				= NSManagedObjectModel().entities

		if let _demoEntitiesNames = self.demoEntities {
			entities = _demoEntitiesNames
		}

		for desc in entities {
			array.append(desc.managedObjectClassName);
		}
		return array
	}

	override class func setupDatabaseWithName(databaseName: String, didResetDatabase: (() -> Void)?) {

		self.setupDatabaseDidResetCalled = true

		var didResetDB = false
		if (DKDBManager.resetStoredEntities() == true) {
			didResetDB = self.eraseDatabaseForStoreName(databaseName)
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

		self.dumpCountInContextIsCalled = true
	}


	override class func dump() {
		self.dumpInContext(self.context)
	}

	override class func dumpInContext(context: NSManagedObjectContext) {

		if (self.verbose() == false) {
			self.dumpInContextIsCalled 		= false
		} else {
			self.dumpInContextIsCalled		= true
		}
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
		self.setupDatabaseDidResetCalled	= false
		self.demoEntities?.removeAll()
	}
}
