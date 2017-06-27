//
//  Passenger.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import CoreData
import DKHelper

class Passenger: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	var allBaggagesCount : Int {
		return self.mutableSetValue(forKey: JSON.Baggages).count
	}

	var allBaggages : NSMutableSet {
		return self.mutableSetValue(forKey: JSON.Baggages)
	}

	var allBaggagesArray : [Baggage] {
		let sortDescriptor = NSSortDescriptor(key: JSON.Weight, ascending: true)
		return (self.allBaggages.sortedArray(using: [sortDescriptor]) as? [Baggage] ?? [])
	}
}

// MARK: - DKDBManager

extension Passenger {

	override var description : String {
		var description = "\(self.objectID.uriRepresentation().lastPathComponent)"
		if let n = self.name {
			description += ": \(n)"
		}
		if let age = self.age as? Int {
			description += ", \(age) yo"
		}
		description += ", \(self.allBaggagesCount) Baggage(s)"

		if let plane = self.plane?.objectID.uriRepresentation().lastPathComponent {
			description += ", plane: \(plane)"
		}
		return description
	}

	override func saveEntityAsNotDeprecated() {
		super.saveEntityAsNotDeprecated()

		for baggage in self.allBaggages {
			(baggage as? Baggage)?.saveEntityAsNotDeprecated()
		}
	}

	override func update(with dictionary: [AnyHashable: Any]?, in savingContext: NSManagedObjectContext) {
		super.update(with: dictionary, in: savingContext)

		self.name = GET_STRING(dictionary, JSON.Name)
		self.age = GET_NUMBER(dictionary, JSON.Age)

		if let jsonArray = OBJECT(dictionary, JSON.Baggages) as? [[AnyHashable: Any]] {
			if let passengers = Baggage.crudEntities(with: jsonArray, in: savingContext) {
				self.mutableSetValue(forKey: JSON.Baggages).addObjects(from: passengers)
			}
		}
	}

	override func invalidReason() -> String? {

		if let invalidReason = super.invalidReason() {
			return invalidReason
		}

		guard let name = self.name, (name.characters.count > 0) else {
			return "Invalid Name"
		}

		guard let age = self.age as? Int, (age > 0) else {
			return "Invalid age. can't be inferior or equal to 0"
		}

		// valid passenger.
		return nil
	}

	override func deleteEntity(withReason reason: String?, in savingContext: NSManagedObjectContext) {

		for baggage in self.allBaggagesArray {
			baggage.deleteEntity(withReason: "Parent passenger entity removed", in: savingContext)
		}

		super.deleteEntity(withReason: reason, in: savingContext)
	}

	override class func verbose() -> Bool {
		return Verbose.Model.Passenger
	}

	override class func sortingAttributeName() -> String? {
		return JSON.Name
	}

	override class func primaryPredicate(with dictionary: [AnyHashable: Any]?) -> NSPredicate? {
		if let
			name = GET_STRING(dictionary, JSON.Name),
			let age = GET_NUMBER(dictionary, JSON.Age) {
				return NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Name, name, JSON.Age, age)
		}
		return super.primaryPredicate(with: dictionary)
	}

	override func shouldUpdateEntity(with dictionary: [AnyHashable: Any]?, in savingContext: NSManagedObjectContext) -> Bool {
		return super.shouldUpdateEntity(with: dictionary, in: savingContext)
	}
}
