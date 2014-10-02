//
//  Runner+Helpers.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import Foundation

extension Runner {

    func description() -> String {
        return "\(self.objectID.URIRepresentation().lastPathComponent) : \(self.name) - \(self.position)"
    }
    
    override public func uniqueIdentifier() -> AnyObject! {
        return self.objectID;
    }
    
    override public func updateWithDictionary(dict: [NSObject : AnyObject]!) {
        self.name = GET_STRING(dict, "name")
        self.position = GET_NUMBER(dict, "position")
    }

    override public func invalidReason() -> String! {
        return nil
    }
    
    override public func deleteChildEntities() -> () {
        //
    }

    override public class func verbose() -> Bool {
        return true
    }
    
    override public class func sortingAttributeName() -> String! {
        return "position"
    }
    
    override public class func primaryPredicateWithDictionary(dictionary: [NSObject:AnyObject]!) -> NSPredicate! {
        // if return nil will only take the first entity created (if any) and update it. By doing so only ONE entity will ever be created.
        // otherwise use the one find bu the predicate.
        return NSPredicate(format: "name ==[c] %@", GET_STRING(dictionary, "name"))
    }

    override public func shouldUpdateEntityWithDictionary(dictionary: [NSObject:AnyObject]!) -> Bool {
        return true
    }

    class func countEntity() {
        println(Runner.MR_findAll())
    }
}