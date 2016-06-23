//
//  Baggage.swift
//  DKDBManager
//
//  Created by kevin delord on 21/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import CoreData
import DKHelper


/// Recreate the `Baggage` class for the unit test by using more default function without override.
class Baggage: NSManagedObject {

	// Insert code here to add functionality to your managed object subclass

}

extension Baggage {

	@NSManaged var weight: NSNumber?
	@NSManaged var passenger: Passenger?

}

// MARK: - DKDBManager

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

	override func updateWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) {
		super.updateWithDictionary(dictionary, inContext: savingContext)

		self.weight = GET_NUMBER(dictionary, JSON.Weight)
	}

	override class func verbose() -> Bool {
		return (super.verbose() || Verbose.Model.Baggage)
	}
}
