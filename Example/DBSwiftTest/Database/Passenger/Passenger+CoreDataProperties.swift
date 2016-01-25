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

    @NSManaged var age: NSNumber?
    @NSManaged var name: String?
    @NSManaged var gender: String?
    @NSManaged var baggages: NSSet?
    @NSManaged var plane: Plane?

}
