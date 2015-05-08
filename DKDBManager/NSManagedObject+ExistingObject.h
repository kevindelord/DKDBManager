//
//  NSManagedObject+ExistingObject.h
//  Digster
//
//  Created by kevin delord on 11/12/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

#import <CoreData/CoreData.h>

/**
 * Categorised Class of an NSManagedObject to `fight` against the sadly famous CoreData crash: 'could not fulfill a fault'.
 * This class has been coded following the question and answers on this SO thread:
 * http://stackoverflow.com/questions/4340445/how-can-i-tell-whether-an-nsmanagedobject-has-been-deleted/7896369#7896369
 */
@interface NSManagedObject (ExistingObject)

/**
 * Verification method to know if the current object is still still valid, if it has been deleted or even if it's still in a valid context.
 *
 * @return TRUE is valid
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasValidContext;

/**
 * Returns YES if |managedObject| has been deleted from the Persistent Store, or NO if it has not.
 *
 * NO will be returned for NSManagedObject's who have been marked for deletion
 * (e.g. their -isDeleted method returns YES), but have not yet been commited
 * to the Persistent Store. YES will be returned only after a deleted
 * NSManagedObject has been committed to the Persistent Store.
 *
 * Rarely, an exception will be thrown if Mac OS X 10.5 is used AND
 * |managedObject| has zero properties defined. If all your NSManagedObject's
 * in the data model have at least one property, this will not be an issue.
 *
 * Property == Attributes and Relationships
 *
 * Mac OS X 10.4 and earlier are not supported, and will throw an exception.
 *
 * @return YES if the current managedObject has been deleted from the Persistent Store, or NO if it has not.
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasBeenDeleted;

/**
 * @return YES the current managedObject exist in the current context, or NO if it has not.
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL doesExist;

/**
 * @return YES the current managedObject has a managed object context, or NO if it has not.
 */
@property (NS_NONATOMIC_IOSONLY, getter=isValidInCurrentContext, readonly) BOOL validInCurrentContext;

@end
