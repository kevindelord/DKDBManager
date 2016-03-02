//
//  Passenger.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import CoreData


class Passenger: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	var allBaggagesCount : Int {
		return self.mutableSetValueForKey(JSON.Baggages).count
	}

	var allBaggages : NSMutableSet {
		return self.mutableSetValueForKey(JSON.Baggages)
	}

	var allBaggagesArray : [Baggage] {
		let sortDescriptor = NSSortDescriptor(key: JSON.Weight, ascending: true)
		return (self.allBaggages.sortedArrayUsingDescriptors([sortDescriptor]) as? [Baggage] ?? [])
	}
}

// MARK: - DKDBManager

extension Passenger {

	override var description : String {
		var description = "\(self.objectID.URIRepresentation().lastPathComponent ?? "")"
		if let n = self.name {
			description += ": \(n)"
		}
		if let age = self.age as? Int {
			description += ", \(age) yo"
		}
		description += ", \(self.allBaggagesCount) Baggage(s)"

		if let plane = self.plane?.objectID.URIRepresentation().lastPathComponent {
			description += ", plane: \(plane)"
		}
		return description
	}

	override func uniqueIdentifier() -> AnyObject {
		return self.objectID;
	}

	override func saveEntityAsNotDeprecated() {
		super.saveEntityAsNotDeprecated()

		for baggage in self.allBaggages {
			(baggage as? Baggage)?.saveEntityAsNotDeprecated()
		}
	}

	override func updateWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) {
		super.updateWithDictionary(dictionary, inContext: savingContext)

		self.name = GET_STRING(dictionary, JSON.Name)
		self.age = GET_NUMBER(dictionary, JSON.Age)

		if let jsonArray = OBJECT(dictionary, JSON.Baggages) as? [[NSObject : AnyObject]] {
			if let passengers = Baggage.createEntitiesFromArray(jsonArray, inContext: savingContext) {
				self.mutableSetValueForKey(JSON.Baggages).addObjectsFromArray(passengers)
			}
		}
	}

	override func invalidReason() -> String? {

		if let invalidReason = super.invalidReason() {
			return invalidReason
		}

		guard let name = self.name where (name.characters.count > 0) else {
			return "Invalid Name"
		}

		guard let age = self.age as? Int where (age > 0) else {
			return "Invalid age. can't be inferior or equal to 0"
		}

		// valid passenger.
		return nil
	}

	override func deleteEntityWithReason(reason: String?, inContext savingContext: NSManagedObjectContext) {

		for baggage in self.allBaggagesArray {
			baggage.deleteEntityWithReason("Parent passenger entity removed", inContext: savingContext)
		}

		super.deleteEntityWithReason(reason, inContext: savingContext)
	}

	override class func verbose() -> Bool {
		return Verbose.Model.Passenger
	}

	override class func sortingAttributeName() -> String? {
		return JSON.Name
	}

	override class func primaryPredicateWithDictionary(dictionary: [NSObject:AnyObject]?) -> NSPredicate? {
		if let
			name = GET_STRING(dictionary, JSON.Name),
			age = GET_NUMBER(dictionary, JSON.Age) {
				return NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Name, name, JSON.Age, age)
		}
		return super.primaryPredicateWithDictionary(dictionary)
	}

	override func shouldUpdateEntityWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) -> Bool {
		return true
	}
}