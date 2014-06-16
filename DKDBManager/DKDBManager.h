//
//  DKDBManager.h
//  WhiteWall
//
//  Created by kevin delord on 21/02/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#ifndef DKDBManager_h__
#define DKDBManager_h__

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DKHelper.h"
#import "CoreData+MagicalRecord.h"
#import "NSManagedObject+DKDBManager.h"

@interface DKDBManager : NSObject

#pragma mark - DEBUG

/**
 * Returns a Boolean value indicating whether the manager is set as verbose.
 * Default value NO.
 *
 * @return YES if the manager is verbose.
 */
+ (BOOL)verbose;

/**
 * Set a Boolean value indicating whether the manager is set as verbose or not.
 * @param Boolean value.
 */
+ (void)setVerbose:(BOOL)verbose;

/**
 * Returns a Boolean value indicating whether the manager allows updates to the different model entities.
 * If this boolean is set to NO then entities won't be updated anymore. Just new ones will be created with new values.
 * The result of the method: 'shouldNotUpdateEntity:withDictionary:' will be ignored.
 * Default value YES.
 *
 * @return YES if the manager allows updates to the model entities.
 */
+ (BOOL)allowUpdate;

/**
 * Set a Boolean value indicating whether the manager allows updates or not.
 * @param Boolean value.
 */
+ (void)setAllowUpdate:(BOOL)allowUpdate;

/**
 * Returns a Boolean value indicating whether the manager will reset all stored entities on setup.
 * Default value NO.
 *
 * @return YES if the manager need to reset all stored entities.
 */
+ (BOOL)resetStoredEntities;

/**
 * Set a Boolean value indicating whether the manager will reset all stored entities or not.
 * @param Boolean value.
 */
+ (void)setResetStoredEntities:(BOOL)resetStoredEntities;

/**
 * Returns a Boolean value indicating whether the manager will force the update to the different model entities..
 * If this boolean is set to yes then an entity will always be updated with a given dictionnary inside the method: 'createEntityWithDictionary:'.
 * The result of the method: 'shouldNotUpdateEntity:withDictionary:' will be ignored.
 * Default value NO.
 *
 * @return YES if the manager need to reset all stored entities.
 */
+ (BOOL)needForcedUpdate;

/**
 * Set a Boolean value indicating whether the manager will force the update of the entities or not.
 * @param Boolean value.
 */
+ (void)setNeedForcedUpdate:(BOOL)needForcedUpdate;

/**
 * TODO
 */
+ (void)dump;

/**
 * TODO
 */
+ (void)dumpCount;

#pragma mark - DB methods

/**
 * Create and a return a singleton shared instance of the current manager class.
 * @return A singleton instance of the manager.
 */
+ (instancetype)sharedInstance;

/**
 * Asynchronously saves the current context into its persistent store.
 */
+ (void)save;

/**
 * Synchronously saves the current context into its persistent store.
 */
+ (void)saveToPersistentStoreAndWait;

/**
 * Asynchronously saves the current context into its persistent store and execute the completion block when is done.
 */
+ (void)saveToPersistentStoreWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

/**
 * Depending on your database logic, app architecture, APIs, etc., each entity could be saved into a local array to save them as not deprecated.
 * By doing so they won't be removed when the method "removeDeprecatedEntities" is called.
 * This method is called inside the 'createEntityFromDictionary:' method.
 * To improve the removal of deprecated entities it is extremely adviced to save the ID of each child entities/relations.
 * If implemented properly an entity will be removed if its parent is.
 *
 * @param id The entity to store as not deprecated
 * @param entity The NSString describing the entity name 
 */
+ (void)saveId:(NSString *)id forEntity:(NSString *)entity;

/**
 * Reset (if needed) and setup the core data stack.
 *
 * @param databaseName The NSString object containing the name of the database. Shouldn't be nil.
 * @param identifier The NSString object containing an identifier of the current database. For example if you want to have different database for different APIs. Shouldn't be nil.
 * @param storingKey The NSString object describing the key to use to save the identifier into the NSUserDefaults. Shouldn't be nil.
 * @return YES if the database has been reset. 
 */
+ (BOOL)setupDatabaseWithName:(NSString *)databaseName identifier:(NSString *)identifier forKey:(NSString *)storingKey;

/**
 * TODO: logic should be improved
 */
+ (void)removeDeprecatedEntities;

@end

#endif
