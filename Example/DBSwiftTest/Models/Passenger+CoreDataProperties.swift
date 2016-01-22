//
//  Passenger+CoreDataProperties.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Passenger {

    @NSManaged var name: String?
    @NSManaged var age: NSNumber?
    @NSManaged var plane: Plane?
    @NSManaged var baggages: Baggage?

}
