//
//  DKDBManager.h
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
 *
 * @param Boolean value.
 */
+ (void)setVerbose:(BOOL)verbose;

/**
 * Returns a Boolean value indicating whether the manager allows updates to the different model entities.
 * If this boolean is set to NO then entities won't be updated anymore. Just new ones will be created with new values.
 * The result of the method: 'shouldUpdateEntity:withDictionary:' will be ignored.
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
 * Returns a Boolean value indicating whether the manager will force the update to the different model entities.
 * If this boolean is set to yes then an entity will always be updated with a given dictionnary inside the method: 'createEntityWithDictionary:'.
 * The result of the method: 'shouldUpdateEntity:withDictionary:' will be ignored.
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

#pragma mark - Log

/**
 * Dump the database iff the log is enable.
 *
 * @discussion Will log in the console the number of entities per model and then get and display the description of every objects.
 * The entities are sorted by class and then by following the DKDBManagedObject protocol. 
 *
 * @see + (BOOL)verbose;
 * @see + (NSString *)sortingAttributeName;
 */
+ (void)dump;

/**
 * Dump the number of entities per model in the database iff the log is enable.
 */
+ (void)dumpCount;

#pragma mark - DB methods

/**
 * Create and a return a singleton shared instance of the current manager class.
 * @return A singleton instance of the manager.
 */
+ (instancetype)sharedInstance;

/**
 * Cleanup the CoreData stack before the app exits.
 *
 * @discussion Should be called on the `applicationWillTerminate:` AppDelegate's method.
 */
+ (void)cleanUp;

/**
 * Setup, and reset if needed, the CoreData stack using an auto migrating system.
 *
 * @discussion
 * Of course you can play with the name to change your database on startup whenever you would like to.
 * A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions`
 * method of your `AppDelegate`.
 *
 * @param databaseName The NSString object containing the name of the database. Shouldn't be nil and can be modified on startup. 
 * @return YES if the database has been reset. 
 */
+ (BOOL)setupDatabaseWithName:(NSString *)databaseName;

#pragma mark - Delete methods

/**
 * Delete all saved entities from the current context for all models in the current database. Does not 'hard' reset the entire sqlite file.
 */
+ (void)deleteAllEntities;

/**
 * Delete all saved entities from the current context for one specific model in the current database.
 *
 * @param class The Class object referencing the model to delete the entities. 
 */
+ (void)deleteAllEntitiesForClass:(Class)class;

#pragma mark - Save methods

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
 * Depending on your database logic, app architecture, APIs, etc., each entity's uniqueIdentifier` could be saved into
 * a local array as not deprecated. By doing so they won't be removed when the method "removeDeprecatedEntities" is called.
 * The 'saveEntity:' method is called from the 'createEntityFromDictionary:' one.
 * To improve the removal of deprecated entities it is extremely adviced to save the ID of each child entities and relationships.
 * If implemented properly an entity will be removed also if its parent is.
 *
 * @param entity The entity object to store as not deprecated
 */
+ (void)saveEntity:(id)entity;

#pragma mark - Delete methods

/**
 * Call `removeDeprecatedEntitiesFromArray:` method for every class returned by the `entities` one.
 *
 * @discussion
 * Only the saved objects through the `saveEntity:` method will NOT be removed as they are saved as *not deprecated*.
 * All other entities will be removed.
 */
+ (void)removeDeprecatedEntities;

/**
 * Do a `cleanUp` and completely remove the sqlite file from the disk.
 *
 * @discussion If the file referenced by the given database name couldn't be find a UIAlertView will be shown.
 *
 * @return YES if the database has been reset. 
 */
+ (BOOL)eraseDatabaseForStoreName:(NSString *)databaseName;

@end

#endif
