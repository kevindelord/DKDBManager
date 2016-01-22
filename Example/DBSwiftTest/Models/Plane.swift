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

