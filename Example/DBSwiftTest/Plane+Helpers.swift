//
//  Runner+Helpers.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import Foundation

extension Plane {

	override var description : String {
		return "\(self.objectID.URIRepresentation().lastPathComponent ?? "") : \(self.origin ?? "") -> \(self.destination ?? "") | \(self.passengers ?? "")"
	}

	override func uniqueIdentifier() -> AnyObject {
		return self.objectID;
	}

	override func saveEntityAsNotDeprecated() {
		super.saveEntityAsNotDeprecated()
	}

	override func updateWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) {
		self.origin = GET_STRING(dictionary, JSON.Origin)
		self.destination = GET_STRING(dictionary, JSON.Destination)
	}

	override func invalidReason() -> String? {

		guard let origin = self.origin where (origin.characters.count > 0) else {
			return "Invalid Origin"
		}

		guard let destination = self.origin where (destination.characters.count > 0) else {
			return "Invalid Destination"
		}

		if (origin == destination) {
			return "Cannot have same origin and destination"
		}

		// valid plane.
		return nil
	}


	override func deleteChildEntitiesInContext(context: NSManagedObjectContext) {
		//
	}

	override class func verbose() -> Bool {
		return true
	}

	override class func sortingAttributeName() -> String? {
		return JSON.Origin
	}

	override class func primaryPredicateWithDictionary(dictionary: [NSObject:AnyObject]?) -> NSPredicate? {
		if let
			origin = GET_STRING(dictionary, JSON.Origin),
			destination = GET_STRING(dictionary, JSON.Destination) {
				return NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, origin, JSON.Destination, destination)
		}
		return nil
	}

	override func shouldUpdateEntityWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) -> Bool {
		return true
	}
}