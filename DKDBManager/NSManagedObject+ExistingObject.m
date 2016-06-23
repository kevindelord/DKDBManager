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
	return (self.doesExist == NO);
}

@end
