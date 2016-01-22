//
//  Plane.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import CoreData


class Plane: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	var allPassengersCount : Int {
		return self.mutableSetValueForKey(JSON.Passengers).count
	}

	var allPassengers : NSMutableSet {
		return self.mutableSetValueForKey(JSON.Passengers)
	}

	var allPassengersArray : [Passenger] {
		let sortDescriptor = NSSortDescriptor(key: JSON.Name, ascending: true)
		return (self.allPassengers.sortedArrayUsingDescriptors([sortDescriptor]) as? [Passenger] ?? [])
	}

	func entityInContext(context: NSManagedObjectContext) -> Plane? {
		if let
			origin = self.origin,
			destination = self.destination {
				let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, origin, JSON.Destination, destination)
				return Plane.MR_findFirstWithPredicate(predicate, inContext: context)
		}
		return nil
	}
}

// MARK: - DKDBManager

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
