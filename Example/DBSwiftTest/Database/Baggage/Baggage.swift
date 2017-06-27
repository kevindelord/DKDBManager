//
//  Baggage.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import CoreData
import DKHelper

class Baggage: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

// MARK: - DKDBManager

extension Baggage {

	override var description : String {
		var description = "\(self.objectID.uriRepresentation().lastPathComponent)"
		if let w = self.weight as? Int {
			description += ": \(w) kg"
		}
		if let passenger = self.passenger?.objectID.uriRepresentation().lastPathComponent {
			description += ", passenger: \(passenger)"
		}
		return description
	}

	override func saveEntityAsNotDeprecated() {
		super.saveEntityAsNotDeprecated()
	}

	override func update(with dictionary: [AnyHashable: Any]?, in savingContext: NSManagedObjectContext) {
		super.update(with: dictionary, in: savingContext)

		self.weight = GET_NUMBER(dictionary, JSON.Weight)
	}

	override func invalidReason() -> String? {

		if let invalidReason = super.invalidReason() {
			return invalidReason
		}

		guard let weight = self.weight as? Int, (weight > 0) else {
			return "Invalid weight"
		}

		// valid baggage.
		return nil
	}

	override class func verbose() -> Bool {
		return Verbose.Model.Baggage
	}

	override func deleteEntity(withReason reason: String?, in savingContext: NSManagedObjectContext) {
		super.deleteEntity(withReason: reason, in: savingContext)
	}

	override class func sortingAttributeName() -> String? {
		return JSON.Weight
	}

	override class func primaryPredicate(with dictionary: [AnyHashable: Any]?) -> NSPredicate? {
		return NSPredicate(format: "FALSEPREDICATE")
	}

	override func shouldUpdateEntity(with dictionary: [AnyHashable: Any]?, in savingContext: NSManagedObjectContext) -> Bool {
		return true
	}
}
