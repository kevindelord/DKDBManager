//
//  NSManagedObject+ExistingObject.m
//  Digster
//
//  Created by kevin delord on 11/12/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

#import "NSManagedObject+ExistingObject.h"

@implementation NSManagedObject (ExistingObject)

- (BOOL)isValidInCurrentContext {
	return (    self.isDeleted          == NO
			&&  self.hasBeenDeleted     == NO
			&&  self.doesExist          == YES
			&&  self.hasValidContext    == YES);
}

- (BOOL)doesExist {
	NSManagedObjectContext *moc = [self managedObjectContext];
	if ([moc existingObjectWithID:self.objectID error:NULL]) {
		// object is valid, go ahead and use it
		return YES;
	}
	return NO;
}

- (BOOL)hasValidContext {
	if (self.managedObjectContext == nil) {
		// Assume that the managed object has been deleted.
		return NO;
	}
	return YES;
}

- (BOOL)hasBeenDeleted {
	/*
	 Returns YES if |managedObject| has been deleted from the Persistent Store,
	 or NO if it has not.

	 NO will be returned for NSManagedObject's who have been marked for deletion
	 (e.g. their -isDeleted method returns YES), but have not yet been commited
	 to the Persistent Store. YES will be returned only after a deleted
	 NSManagedObject has been committed to the Persistent Store.

	 Mac OS X 10.5 and earlier are not supported, and will throw an exception.
	 */
	NSManagedObjectID *objectID = [self objectID];
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSManagedObject *managedObjectClone = [moc existingObjectWithID:objectID error:NULL];

	if (!managedObjectClone) {
		return YES;                 // Deleted.
	} else {
		return NO;                  // Not deleted.
	}
}

@end
