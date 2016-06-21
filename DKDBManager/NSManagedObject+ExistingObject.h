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
 * @brief Verification method to know if the current object is still valid, if it has been deleted or even if it's still in a valid context.
 *
 * @return TRUE is valid
 */
@property (nonatomic, readonly) BOOL hasValidContext;

/**
 * @return YES if the current managedObject has been deleted from the Persistent Store, or NO if it has not.
 */
@property (nonatomic, readonly) BOOL hasBeenDeleted NS_AVAILABLE(10_6, 3_0);

/**
 * @return YES the current managedObject exist in the current context, or NO if it has not.
 */
@property (nonatomic, readonly) BOOL doesExist;

/**
 * @return YES the current managedObject has a managed object context, or NO if it has not.
 */
@property (nonatomic, readonly) BOOL isValidInCurrentContext NS_AVAILABLE(10_6, 3_0);

@end
