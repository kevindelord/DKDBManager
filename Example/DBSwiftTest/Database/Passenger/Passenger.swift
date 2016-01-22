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

	func entityInContext(context: NSManagedObjectContext) -> Passenger? {
		if let
			name = self.name,
			age = self.age {
				let predicate = NSPredicate(format: "%K ==[c] %@ && %K ==[c] %@", JSON.Name, name, JSON.Age, age)
				return Passenger.MR_findFirstWithPredicate(predicate, inContext: context)
		}
		return nil
	}

}
