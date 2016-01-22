//
//  Runner+Helpers.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import Foundation
import DKHelper

extension Plane {

	override var description : String {
		return "\(self.objectID.URIRepresentation().lastPathComponent ?? "") : \(self.origin ?? "") -> \(self.destination ?? ""), \(self.allPassengersCount) Passenger(s)"
	}

	override func uniqueIdentifier() -> AnyObject {
		return self.objectID;
	}

	override func saveEntityAsNotDeprecated() {
		super.saveEntityAsNotDeprecated()

 		for passenger in self.allPassengers {
			(passenger as? Passenger)?.saveEntityAsNotDeprecated()
		}
	}

	override func updateWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) {
		self.origin = GET_STRING(dictionary, JSON.Origin)
		self.destination = GET_STRING(dictionary, JSON.Destination)

		if let jsonArray = OBJECT(dictionary, JSON.Passengers) as? [[NSObject : AnyObject]] {
			if let passengers = Passenger.createEntitiesFromArray(jsonArray, inContext: savingContext) {
				self.mutableSetValueForKey(JSON.Passengers).addObjectsFromArray(passengers)
			}
		}
	}

	override func invalidReason() -> String? {

		guard let origin = self.origin where (origin.characters.count > 0) else {
			return "Invalid Origin"
		}

		guard let destination = self.destination where (destination.characters.count > 0) else {
			return "Invalid Destination"
		}

		if (origin == destination) {
			return "Cannot have same origin and destination: \(origin) == \(destination)"
		}

		// valid plane.
		return nil
	}

	override func deleteEntityWithReason(reason: String?, inContext savingContext: NSManagedObjectContext) {

		for passenger in self.allPassengersArray {
			passenger.deleteEntityWithReason("Parent plane entity removed", inContext: savingContext)
		}

		super.deleteEntityWithReason(reason, inContext: savingContext)
	}

	override class func verbose() -> Bool {
		return Verbose.Model.Plane
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