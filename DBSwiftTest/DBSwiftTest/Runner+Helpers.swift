//
//  Runner+Helpers.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import Foundation

extension Runner {

	public override var description : String {
        return "\(self.objectID.URIRepresentation().lastPathComponent) : \(self.name) - \(self.position)"
    }

    override public func uniqueIdentifier() -> AnyObject {
        return self.objectID;
    }

    override public func updateWithDictionary(dict: [NSObject : AnyObject]?) {
        self.name = GET_STRING(dict, "name")
        self.position = GET_NUMBER(dict, "position")
    }

    override public func invalidReason() -> String? {
        return nil
    }


	public override func deleteChildEntitiesInContext(context: NSManagedObjectContext) {
		//
	}

    override public class func verbose() -> Bool {
        return true
    }

    override public class func sortingAttributeName() -> String? {
        return "position"
    }

    override public class func primaryPredicateWithDictionary(dictionary: [NSObject:AnyObject]?) -> NSPredicate? {
        // if return nil will only take the first entity created (if any) and update it. By doing so only ONE entity will ever be created.
        // otherwise use the one find bu the predicate.
		if let name = GET_STRING(dictionary, "name") {
        	return NSPredicate(format: "name ==[c] %@", name)
		}
		return nil
    }

    override public func shouldUpdateEntityWithDictionary(dictionary: [NSObject:AnyObject]?) -> Bool {
        return true
    }

    class func countEntityInContext(context: NSManagedObjectContext) {
        print(Runner.MR_findAllInContext(context))
    }
}