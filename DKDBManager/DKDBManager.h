//
//  DKDBManager.h
//
//  Created by kevin delord on 21/02/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#ifndef DKDBManager_h__
#define DKDBManager_h__

#define DK_DEPRECATED_PLEASE_USE(METHOD) __attribute__((deprecated("Deprecated method. Please use `" METHOD "` instead.")))

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>
#import "NSManagedObject+DKDBManager.h"
#import "NSManagedObject+ExistingObject.h"

/**
 *  DKDBManager is simple, yet very useful, CRUD manager around Magical Record (a CoreData wrapper).
 *  The current library implement a CRUD logic around it and helps the developer to manage his entities.
 *
 *  The main concept is to use JSON dictionaries representing the entities.
 *  The logic to create, read or update entities is done with just one single function.
 *  The delete logic has also been improved with a `deprecated` state.
 *
 *  Extend the NSManagedObject subclasses is required.
 *  Please read the README.md for more information.
 */
@interface DKDBManager : MagicalRecord

/**
 *  Dictionnary containing identifiers of all entities marked as not deprecated.
 *
 *  If the identifier of an entity is not contained in this dictionary, the entity will be considered as deprecated.
 *
 *  @remark The value can not be `nil`; to reinitialise the stored identifiers, create a new NSMutableDictionary.
 */
@property (nonnull, nonatomic, retain) NSMutableDictionary * storedIdentifiers;

#pragma mark - DEBUG

/**
 *  @brief Boolean indicating whether the manager is set as verbose or not.
 *
 *  @discussion Default is FALSE.
 *
 *  @return TRUE if the manager is verbose; otherwise FALSE.
 */
+ (BOOL)verbose;

/**
 *  @brief Set a Boolean value indicating whether the manager is set as verbose or not.
 *
 *  @param verbose Boolean value.
 */
+ (void)setVerbose:(BOOL)verbose;

/**
 *  @brief Boolean indicating whether the manager will allow updates on the database entities or not.
 *
 *  @discussion Returns a Boolean value indicating whether the manager allows updates to the different model entities.
 *
 *  If this boolean is set to FALSE then entities won't be updated anymore. Just new ones will be created with new values.
 *  Moreover, the result of the method: `shouldUpdateEntity:withDictionary:` will be ignored.
 *
 *  Default value is TRUE.
 *
 *  @return TRUE if the manager allows updates to the model entities; otherwise FALSE.
 */
+ (BOOL)allowUpdate;

/**
 *  @brief Set a Boolean value indicating whether the manager allows updates or not.
 *
 *  @param allowUpdate Boolean value.
 */
+ (void)setAllowUpdate:(BOOL)allowUpdate;

/**
 *  @brief Boolean indicating whether the manager will reset all stored entities on setup or not.
 *
 *  @discussion Default value FALSE.
 *
 *  @return TRUE if the manager need to reset all stored entities; otherwise FALSE.
 */
+ (BOOL)resetStoredEntities;

/**
 *  @brief Set a Boolean value indicating whether the manager will reset all stored entities or not.
 *
 *  @param resetStoredEntities Boolean value.
 */
+ (void)setResetStoredEntities:(BOOL)resetStoredEntities;

/**
 *  @brief Boolean indicating whether the manager will force the update over the database entities or not.
 *
 *  @discussion Returns a Boolean value indicating whether the manager will force the update to the different model entities.
 *
 *  If this boolean is set to TRUE then an entity will always be updated with a given dictionnary inside the method   `createEntityWithDictionary:`. Moreover, the result of the `shouldUpdateEntity:withDictionary:` method will be ignored.
 *
 *  Default value FALSE.
 *
 *  @return TRUE if the manager need to reset all stored entities; otherwise FALSE.
 */
+ (BOOL)needForcedUpdate;

/**
 *  @brief Set a Boolean value indicating whether the manager will force the update of the entities or not.
 *
 *  @param needForcedUpdate Boolean value.
 */
+ (void)setNeedForcedUpdate:(BOOL)needForcedUpdate;

/**
 *  @brief Returns an array of NSString objects corresponding to the class name of all model entities in the current database.
 *
 *  @discussion The Abstract entities are not including.
 *
 *  @return A NSArray object containing all class names in the database.
 */
+ (NSArray * _Nonnull)entityClassNames;

#pragma mark - Log

/**
 *  @brief Dump the database within a specific context; if and only if the log is enabled.
 *
 *  @discussion Will log the number of entities per model and then the description of every single object.
 *
 *  The entities are sorted by class and by their default sorting attribute.
 *
 *  @param context The context from where all entities will be fetched.
 *
 *  @see + (BOOL)verbose;
 *  @see + (NSString *)sortingAttributeName;
 */
+ (void)dumpInContext:(NSManagedObjectContext * _Nonnull)context;

/**
 *  @brief Dump the database using the default NSManagedObjectContext object; if and only if the log is enabled.
 *
 *  @discussion Will log the number of entities per model and then the description of every single object.
 *
 *  The entities are sorted by class and by their default sorting attribute.
 *
 *  This method uses a NSManagedObjectContext object operating on the main thread (simple and single-threaded operations only).
 *
 *  @see + (BOOL)verbose;
 *  @see + (NSString *)sortingAttributeName;
 */
+ (void)dump;

/**
 *  @brief Dump the number of entities per model in the database within a specific context; if and only if the log is enabled.
 *
 *  @see + (BOOL)verbose;
 */
+ (void)dumpCountInContext:(NSManagedObjectContext * _Nonnull)context;

/**
 *  @brief Dump the number of entities per model in the database using the default NSManagedObjectContext object; if and only if the log is enabled.
 *
 *  This method uses a NSManagedObjectContext object operating on the main thread (simple and single-threaded operations only).
 *
 *  @see + (BOOL)verbose;
 */
+ (void)dumpCount;

#pragma mark - DB methods

/**
 *  @brief Create and a return a singleton shared instance of the current manager class.
 *
 *  @return A singleton instance of the manager.
 */
+ (instancetype _Nonnull)sharedInstance;

/**
 *  @brief Setup, and reset if needed, the datamodel using an auto migrating system.
 *
 *  @discussion A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions` method of your `AppDelegate`.
 *
 *  The `didResetDatabaseBlock` block is only called if the database has been erased and recreated.
 *  Depending on your needs you might want to do something special right now as:
 *
 *    - Setting up some user defaults.
 *
 *    - Deal with your api/store manager.
 *
 *    - etc.
 *
 *  @param databaseName The NSString object containing the name of the database. Must not be nil and can be modified on startup.
 *
 *  @param didResetDatabaseBlock Block called if the datamodel file has been completely erased and recreated.
 */
+ (void)setupDatabaseWithName:(NSString * _Nonnull)databaseName didResetDatabase:(void (^ _Nullable)())didResetDatabaseBlock;

/**
 *  @brief Setup, and reset if needed, the datamodel using an auto migrating system.
 *
 *  @discussion A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions` method of your `AppDelegate`.
 *
 *  @param databaseName The NSString object containing the name of the database. Must not be nil and can be modified on startup.
 */
+ (void)setupDatabaseWithName:(NSString * _Nonnull)databaseName;

/**
 *  @brief Setup, and reset if needed, the datamodel using an auto migrating system.
 *
 *  @discussion A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions` method of your `AppDelegate`.
 *
 *  The database filename will be generating using the app's bundle identifier.
 */
+ (void)setup;

/**
 *  @brief Function to clean up the CoreData stack, the defaults contexts and error handlers.
 *
 *  @discussion This function should be called from the `applicationWillTerminate` function of the AppDelegate.
 */
+ (void)cleanUp;

#pragma mark - SAVE

/**
 *  @brief Asynchronously executes and saves modifications into the persistent store.
 *
 *  @discussion Perform saving operations on a background thread.
 *
 *  @see Official documentation: https://github.com/magicalpanda/MagicalRecord/wiki/Saving-Entities
 *  @see Mobe about NSManagedObjectContext: https://github.com/magicalpanda/MagicalRecord/wiki/Working-with-Managed-Object-Contexts
 *
 *  @param block Block executed to perform saving changes using the `savingContext` instance. Every operation is done on a background thread.
 */
+ (void)saveWithBlock:(void(^ _Nullable)(NSManagedObjectContext * _Nonnull savingContext))block;

/**
 *  @brief Asynchronously executes and saves modifications into the persistent store and executes the completion block when it is done.
 *
 *  @discussion Perform saving operations on a background thread. The completion block is called on the main one.
 *
 *  @see Official documentation: https://github.com/magicalpanda/MagicalRecord/wiki/Saving-Entities
 *  @see Mobe about NSManagedObjectContext: https://github.com/magicalpanda/MagicalRecord/wiki/Working-with-Managed-Object-Contexts
 *
 *  @param block Block executed to perform saving changes using the `savingContext` instance. Every operation is done on a background thread.
 *
 *  @param completion Block executed on the main thread once the saving has been completed.
 */
+ (void)saveWithBlock:(void(^ _Nullable)(NSManagedObjectContext * _Nonnull savingContext))block completion:(MRSaveCompletionHandler _Nullable)completion;

/**
 *  @brief Synchronously executes and saves modifications into the persistent store.
 *
 *  @discussion Perform saving operations on the main thread. Be careful by using such function, it could slow down your application.
 *
 *  Nonetheless this is very useful when you're managing your own threads/queues and need a serial call to create or change data.
 *
 *  @see Official documentation: https://github.com/magicalpanda/MagicalRecord/wiki/Saving-Entities
 *  @see Mobe about NSManagedObjectContext: https://github.com/magicalpanda/MagicalRecord/wiki/Working-with-Managed-Object-Contexts
 *
 *  @param block Block executed to perform saving changes using the `savingContext` instance. Every operation is done on a background thread.
 */
+ (void)saveWithBlockAndWait:(void(^ _Nullable)(NSManagedObjectContext * _Nonnull savingContext))block;

/**
 *  @brief Save the given entity as not deprecated.
 *
 *  @discussion Depending on your database logic, app architecture, APIs, etc., each entity's `uniqueIdentifier` could be saved into
 *  a local array as not deprecated.
 *
 *  By doing so they won't be removed when the method `removeDeprecatedEntitiesInContext:` is called.
 *
 *  The `saveEntityAsNotDeprecated:` method is automatically called from the `createEntityFromDictionary:inContext:` one.
 *
 *  To improve the removal of deprecated entities it is extremely adviced to save the ID of each child entities and relationships.
 *  If implemented properly an entity will be removed also if its parent is.
 *
 *  @param entity The entity object to store as not deprecated; must not be nil.
 */
+ (void)saveEntityAsNotDeprecated:(id _Nonnull)entity;

#pragma mark - Delete methods

/**
 *  @brief Remove all stored identifiers of non-deprecated entities.
 *
 *  @remark The related entities will be considered as deprecated by the manager.
 *
 *  @see Variable `NSMutableDictionary * storedIdentifiers`
 */
+ (void)removeAllStoredIdentifiers;

/**
 *  @brief Remove all stored identifiers of non-deprecated entities for a specific class.
 *
 *  @remark The related entities will be considered as deprecated by the manager.
 *
 *  @see Variable `NSMutableDictionary * storedIdentifiers`
 *
 *  @param class The Class object referencing the model to delete the identifiers.
 */
+ (void)removeAllStoredIdentifiersForClass:(Class _Nonnull)class;

/**
 *  @brief Remove all deprecated entities for every model class within a specific context.
 *
 *  @discussion All entities not marked as not deprecated (using the `saveEntityAsNotDeprecated:` method ) will be removed.
 *
 *  This function calls `removeDeprecatedEntitiesFromArray:inContext:` method for each model class returned by the `entityClassNames` function.
 *
 *  @remark The `cleanUp` function is called.
 *
 *  @param context Database context to remove the entities from.
 */
+ (void)removeDeprecatedEntitiesInContext:(NSManagedObjectContext * _Nonnull)context;

/**
 *  @brief Remove all deprecated entities for one specific model class within a specific context.
 *
 *  @discussion All entities not marked as not deprecated (using the `saveEntityAsNotDeprecated:` method ) will be removed.
 *
 *  This function calls `removeDeprecatedEntitiesFromArray:inContext:` method for each model class returned by the `entityClassNames` function.
 *
 *  @remark The `cleanUp` function is called.
 *
 *  @param context Database context to remove the entities from.
 *
 *  @param class The Class object referencing the model to remove the deprecated entities.
 */
+ (void)removeDeprecatedEntitiesInContext:(NSManagedObjectContext * _Nonnull)context forClass:(Class _Nonnull)class;

/**
 *  @brief Performs a `cleanUp` and completely remove the sqlite file from the disk.
 *
 *  @discussion If the file referenced by the given database name couldn't be found; an assert will be thrown.
 *
 *  @remark It is your responsability to reset the `storedIdentifiers` depending on your threading and managed object context.
 *
 *  @param databaseName The NSString object containing the name of the database; must not be nil.
 *
 *  @return TRUE if the database has been erased; otherwise FALSE.
 */
+ (BOOL)eraseDatabaseForStoreName:(NSString * _Nonnull)databaseName;

/**
 *  @brief Delete all saved entities from a specific context for all models in the current database.
 *
 *  @discussion Does not 'hard' reset the entire sqlite file.
 *
 *  @remark It is your responsability to reset the `storedIdentifiers` depending on your threading and managed object context.
 *
 *  @param context Database context to delete the entities from.
 */
+ (void)deleteAllEntitiesInContext:(NSManagedObjectContext * _Nonnull)context;

/**
 *  @brief Delete all saved entities from a specific context for one specific model in the current database.
 *
 *  @discussion Does not 'hard' reset the entire sqlite file.
 *
 *  @remark It is your responsability to reset the `storedIdentifiers` depending on your threading and managed object context.
 *
 *  @param class The Class object referencing the model to delete the entities.
 *
 *  @param context Database context to delete the entities from.
 */
+ (void)deleteAllEntitiesForClass:(Class _Nullable)class inContext:(NSManagedObjectContext * _Nonnull)context;

@end

#endif
