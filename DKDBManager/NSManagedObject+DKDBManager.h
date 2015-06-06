//
//  NSManagedObject+DKDBManager.h
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "DKDBManager.h"

typedef NS_ENUM(NSInteger, DKDBManagedObjectState) {
    DKDBManagedObjectStateCreate,
    DKDBManagedObjectStateUpdate,
    DKDBManagedObjectStateSave,
    DKDBManagedObjectStateDelete,
} ;

@interface NSManagedObject (DKDBManager)

#pragma mark - CREATE

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion;
+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)createEntitiesFromArray:(NSArray *)array;

#pragma mark - READ

/**
 * Returns the unique identifier of the current entity.
 *
 * When using the DKDBManager to match a distant database (behind an API)
 * the logic to remove deprecated objects actually use a `uniqueIdentifier`
 * for every class.
 * The identifer of each entity is saved zhen refreshing/creating the entities.
 * It is used when the function `removeDeprecatedEntities` is called.
 * The default value use the native `objectID` property of a NSManagedObject.
 *
 * Override this method to use a custom unique identifer build from a
 * class attribute or anything else.
 *
 * @return the unique identifer of the current model entity.
 */
- (id)uniqueIdentifier;

/**
 * Function to save/store the current object and all its child relations as not deprecated.
 *
 * This function is required when matching an online database behind an API.
 * If the current class model does NOT have any child entities / relations, then 
 * it is not required to implement it.
 *
 * This function is automatically called after creating an entity with: `createEntityFromDictionary:`.
 * Unless the returned state is `.Delete` the current/new entity will be stored as not deprecated.
 * When overriden, call `super` and forward the process to all child entities.
 *
 * The default behavior of the current function is to forward the saving process to its child objects.
 * When the entity is created but its child can not be at the same time, then the developper has to create
 * another function to manually save the objects when they have been checked/created.
 * In few words, call this second function when the `pages` of a `book` has been created.
 * On the second start, when the `book` did not get updated it will got saved with `saveEntityAsNotDeprecated`.
 * The `pages` won't be saved until the second custom function is called.
 *
 * @return nothing
 */
- (void)saveEntityAsNotDeprecated;
- (NSString *)invalidReason;
- (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary *)dictionary;
+ (BOOL)verbose;
+ (NSString *)sortingAttributeName;
+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)all;
+ (NSInteger)count;

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary *)dict;

#pragma mark - DELETE

- (BOOL)deleteIfInvalid;
- (void)deleteChildEntities;
- (void)deleteEntityWithReason:(NSString *)reason;
+ (void)deleteAllEntities;
+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array;

@end
