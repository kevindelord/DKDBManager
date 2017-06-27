//
//  Plane.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import CoreData
import DKHelper

class Plane: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	var allPassengersCount : Int {
		return self.mutableSetValue(forKey: JSON.Passengers).count
	}

	var allPassengers : NSMutableSet {
		return self.mutableSetValue(forKey: JSON.Passengers)
	}

	var allPassengersArray : [Passenger] {
		let sortDescriptor = NSSortDescriptor(key: JSON.Name, ascending: true)
		return (self.allPassengers.sortedArray(using: [sortDescriptor]) as? [Passenger] ?? [])
	}
}

// MARK: - DKDBManager

extension Plane {

	override var description : String {
		return "\(self.objectID.uriRepresentation().lastPathComponent) : \(self.origin ?? "") -> \(self.destination ?? ""), \(self.allPassengersCount) Passenger(s)"
	}

	override func saveEntityAsNotDeprecated() {
		super.saveEntityAsNotDeprecated()

		for passenger in self.allPassengers {
			(passenger as? Passenger)?.saveEntityAsNotDeprecated()
		}
	}

	override func update(with dictionary: [AnyHashable: Any]?, in savingContext: NSManagedObjectContext) {
		super.update(with: dictionary, in: savingContext)

		self.origin = GET_STRING(dictionary, JSON.Origin)
		self.destination = GET_STRING(dictionary, JSON.Destination)

		if let jsonArray = OBJECT(dictionary, JSON.Passengers) as? [[AnyHashable: Any]] {
			if let passengers = Passenger.crudEntities(with: jsonArray, in: savingContext) {
				self.mutableSetValue(forKey: JSON.Passengers).addObjects(from: passengers)
			}
		}
	}

	override func invalidReason() -> String? {

		if let invalidReason = super.invalidReason() {
			return invalidReason
		}

		guard let origin = self.origin, (origin.characters.count > 0) else {
			return "Invalid Origin"
		}

		guard let destination = self.destination, (destination.characters.count > 0) else {
			return "Invalid Destination"
		}

		if (origin == destination) {
			return "Cannot have same origin and destination: \(origin) == \(destination)"
		}

		// valid plane.
		return nil
	}

	override func deleteEntity(withReason reason: String?, in savingContext: NSManagedObjectContext) {

		for passenger in self.allPassengersArray {
			passenger.deleteEntity(withReason: "Parent plane entity removed", in: savingContext)
		}

		super.deleteEntity(withReason: reason, in: savingContext)
	}

	override class func verbose() -> Bool {
		return Verbose.Model.Plane
	}

	override class func sortingAttributeName() -> String? {
		return JSON.Origin
	}

	override class func primaryPredicate(with dictionary: [AnyHashable: Any]?) -> NSPredicate? {
		if let
			origin = GET_STRING(dictionary, JSON.Origin),
			let destination = GET_STRING(dictionary, JSON.Destination) {
				return NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Origin, origin, JSON.Destination, destination)
		}
		return super.primaryPredicate(with: dictionary)
	}

	override func shouldUpdateEntity(with dictionary: [AnyHashable: Any]?, in savingContext: NSManagedObjectContext) -> Bool {
		if let jsonArray = OBJECT(dictionary, JSON.Passengers) as? [[AnyHashable: Any]] {

			if (jsonArray.count != self.allPassengersCount) {
				return true
			}
		}
		return false
	}
}
