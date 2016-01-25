//
//  Plane+CoreDataProperties.swift
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

extension Plane {

    @NSManaged var destination: String?
    @NSManaged var origin: String?
    @NSManaged var passengers: Passenger?

}
