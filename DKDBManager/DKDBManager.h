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
#import "MagicalRecord.h"
#import "NSManagedObject+DKDBManager.h"
#import "NSManagedObject+ExistingObject.h"

#define DK_DEPRECATED_PLEASE_USE(METHOD) __attribute__((deprecated("Deprecated method. Please use `" METHOD "` instead.")))

/**
 * DKDBManager is simple, yet very useful, CRUD manager around Magical Record (a CoreData wrapper).
 * The current library implement a CRUD logic around it and helps the developer to manage his entities.
 *
 * The main concept is to use JSON dictionaries representing the entities.
 * The logic to create, read or update entities is done with just one single function.
 * The delete logic has also been improved with a `deprecated` state.
 *
 * Extend the NSManagedObject subclasses is required.
 * Please read the README.md for more information.
 */
@interface DKDBManager : MagicalRecord

#pragma mark - DEBUG

/**
 * @brief Boolean indicating whether the manager is set as verbose or not.
 *
 * @discussion Default is FALSE.
 *
 * @return TRUE if the manager is verbose.
 */
+ (BOOL)verbose;

/**
 * @brief Set a Boolean value indicating whether the manager is set as verbose or not.
 *
 * @param verbose Boolean value.
 */
+ (void)setVerbose:(BOOL)verbose;

/**
 * @brief Boolean indicating whether the manager will allow updates on the database entities or not.
 *
 * @discussion Returns a Boolean value indicating whether the manager allows updates to the different model entities.
 * If this boolean is set to FALSE then entities won't be updated anymore. Just new ones will be created with new values.
 * The result of the method: 'shouldUpdateEntity:withDictionary:' will be ignored.
 *
 * Default value is TRUE.
 *
 * @return TRUE if the manager allows updates to the model entities.
 */
+ (BOOL)allowUpdate;

/**
 * @brief Set a Boolean value indicating whether the manager allows updates or not.
 *
 * @param allowUpdate Boolean value.
 */
+ (void)setAllowUpdate:(BOOL)allowUpdate;

/**
 * @brief Boolean indicating whether the manager will reset all stored entities on setup or not.
 *
 * @discussion Default value FALSE.
 *
 * @return TRUE if the manager need to reset all stored entities.
 */
+ (BOOL)resetStoredEntities;

/**
 * @brief Set a Boolean value indicating whether the manager will reset all stored entities or not.
 *
 * @param resetStoredEntities Boolean value.
 */
+ (void)setResetStoredEntities:(BOOL)resetStoredEntities;

/**
 * @brief Boolean indicating whether the manager will force the update over the database entities or not.
 *
 * @discussion Returns a Boolean value indicating whether the manager will force the update to the different model entities.
 * If this boolean is set to TRUE then an entity will always be updated with a given dictionnary inside the method: 'createEntityWithDictionary:'.
 * The result of the method: 'shouldUpdateEntity:withDictionary:' will be ignored.
 * Default value FALSE.
 *
 * @return TRUE if the manager need to reset all stored entities.
 */
+ (BOOL)needForcedUpdate;

/**
 * @brief Set a Boolean value indicating whether the manager will force the update of the entities or not.
 *
 * @param needForcedUpdate Boolean value.
 */
+ (void)setNeedForcedUpdate:(BOOL)needForcedUpdate;

/**
 * @brief Returns an array of NSString objects corresponding to the class name of all model entities in the current database.
 *
 * @discussion The Abstract entities are not including.
 *
 * @return A NSArray object containing all class names in the database.
 */
+ (NSArray *)entities;

#pragma mark - Log

/**
 * @brief Dump the database if and only if the log is enabled.
 *
 * @discussion Will log the number of entities per model and then the description of every single object.
 * The entities are sorted by class and by their default sorting attribute.
 *
 * @see + (BOOL)verbose;
 * @see + (NSString *)sortingAttributeName;
 */
+ (void)dump;

/**
 * @brief Dump the number of entities per model in the database if and only if the log is enabled.
 */
+ (void)dumpCount;

#pragma mark - DB methods

/**
 * @brief Create and a return a singleton shared instance of the current manager class.
 *
 * @return A singleton instance of the manager.
 */
+ (instancetype)sharedInstance;

/**
 * @brief Setup, and reset if needed, the CoreData stack using an auto migrating system.
 *
 * @discussion Of course you can play with the name to change your database on startup whenever you would like to.
 * A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions`
 * method of your `AppDelegate`.
 *
 * @param databaseName The NSString object containing the name of the database. Shouldn't be nil and can be modified on startup. 
 * @return TRUE if the database has been reset. 
 */
+ (BOOL)setupDatabaseWithName:(NSString *)databaseName;

#pragma mark - Asynchronous context saving

/**
 * @brief Asynchronously saves the modifications into the persistent store.
 *
 * @discussion Save operations in background; done on a different thread/queue.
 *
 * @see Official documentation: https://github.com/magicalpanda/MagicalRecord/blob/develop/Docs/Saving-Entities.md
 *
 * @param block Block of code to be saved, against the `localContext` instance.
 * Every operation is done on a background thread.
 */
+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;

/**
 * @brief Asynchronously saves the current context into its persistent store.
 */
+ (void)save DK_DEPRECATED_PLEASE_USE("saveWithBlock:");

/**
 * @brief Asynchronously saves the modifications into the persistent store and execute the completion block when it is done.
 *
 * @discussion Save operations in background; done on a different thread/queue.
 *
 * @see Official documentation: https://github.com/magicalpanda/MagicalRecord/blob/develop/Docs/Saving-Entities.md
 *
 * @param block Block of code to be saved, against the `localContext` instance.
 * Every operation is done on a background thread.
 */
+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion;

/**
 * @brief Asynchronously saves the current context into its persistent store and execute the completion block when it is done.
 */
+ (void)saveToPersistentStoreWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock DK_DEPRECATED_PLEASE_USE("saveWithBlock:completion:");

#pragma mark - Synchronous context saving

/**
 * @brief Synchronously saves the current context into its persistent store.
 *
 * @discussion For saving on the current thread as the caller, only with a seperate context. Useful when you're managing your own threads/queues and need a serial call to create or change data.
 *
 * @see Official documentation: https://github.com/magicalpanda/MagicalRecord/blob/develop/Docs/Saving-Entities.md
 *
 * @param block Block of code to be saved, against the `localContext` instance.
 * Every operation is done on a background thread.
 */
+ (void)saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block;

/**
 * @brief Synchronously saves the current context into its persistent store.
 */
+ (void)saveToPersistentStoreAndWait DK_DEPRECATED_PLEASE_USE("saveWithBlockAndWait:");

#pragma mark - Save Entities methods

/**
 * @brief Save the given entity as not deprecated.
 *
 * @discussion Depending on your database logic, app architecture, APIs, etc., each entity's uniqueIdentifier` could be saved into
 * a local array as not deprecated. By doing so they won't be removed when the method "removeDeprecatedEntities" is called.
 * The 'saveEntity:' method is called from the 'createEntityFromDictionary:' one.
 * To improve the removal of deprecated entities it is extremely adviced to save the ID of each child entities and relationships.
 * If implemented properly an entity will be removed also if its parent is.
 *
 * @param entity The entity object to store as not deprecated
 */
+ (void)saveEntityAsNotDeprecated:(id)entity;

#pragma mark - Delete methods

/**
 * @brief Call `removeDeprecatedEntitiesFromArray:` method for every class returned by the `entities` one.
 *
 * @discussion Only the saved objects through the `saveEntity:` method will NOT be removed as they are saved as *not deprecated*.
 * All other entities will be removed.
 */
+ (void)removeDeprecatedEntities;

/**
 * @brief Do a `cleanUp` and completely remove the sqlite file from the disk.
 *
 * @discussion If the file referenced by the given database name couldn't be find an UIAlertView will be shown.
 *
 * @param databaseName The NSString object containing the name of the database.
 *
 * @return TRUE if the database has been erased.
 */
+ (BOOL)eraseDatabaseForStoreName:(NSString *)databaseName;

/**
 * @brief Delete all saved entities from the current context for all models in the current database. Does not 'hard' reset the entire sqlite file.
 */
+ (void)deleteAllEntities;

/**
 * @brief Delete all saved entities from the current context for one specific model in the current database.
 *
 * @param class The Class object referencing the model to delete the entities.
 */
+ (void)deleteAllEntitiesForClass:(Class)class;

@end

#endif
