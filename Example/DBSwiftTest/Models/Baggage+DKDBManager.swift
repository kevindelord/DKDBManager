//
//  Baggage+DKDBManager.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import DKHelper

extension Baggage {

	override var description : String {
		var description = "\(self.objectID.URIRepresentation().lastPathComponent ?? "")"
		if let w = self.weight as? Int {
			description += ": \(w) kg"
		}
		if let passenger = self.passenger?.objectID.URIRepresentation().lastPathComponent {
			description += ", passenger: \(passenger)"
		}
		return description
	}

	override func uniqueIdentifier() -> AnyObject {
		return self.objectID;
	}

	override func saveEntityAsNotDeprecated() {
		super.saveEntityAsNotDeprecated()
	}

	override func updateWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) {
		self.weight = GET_NUMBER(dictionary, JSON.Weight)
	}

	override func invalidReason() -> String? {

		guard let weight = self.weight as? Int where (weight > 0) else {
			return "Invalid weight"
		}

		// valid baggage.
		return nil
	}

	override class func verbose() -> Bool {
		return Verbose.Model.Baggage
	}

	override func deleteEntityWithReason(reason: String?, inContext savingContext: NSManagedObjectContext) {
		super.deleteEntityWithReason(reason, inContext: savingContext)
	}

	override class func sortingAttributeName() -> String? {
		return JSON.Weight
	}

	override class func primaryPredicateWithDictionary(dictionary: [NSObject:AnyObject]?) -> NSPredicate? {
		return NSPredicate(format: "FALSEPREDICATE")
	}

	override func shouldUpdateEntityWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) -> Bool {
		return true
	}
}