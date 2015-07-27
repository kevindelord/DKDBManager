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
 * @brief Returns the unique identifier of the current entity.
 *
 * @discussion When using the DKDBManager to match a distant database (behind an API)
 * the logic to remove deprecated objects actually use a `uniqueIdentifier`
 * for every class.
 * The identifer of each entity is saved when refreshing/creating the entities.
 * It is used when the function `removeDeprecatedEntities` is called.
 *
 * The default value use the native `objectID` property of a NSManagedObject.
 *
 * Override this method to use a custom unique identifer build from a
 * class attribute or anything else.
 *
 * @return the unique identifer of the current model entity.
 */
- (id)uniqueIdentifier;

/**
 * @brief Function to store the current object and all its child relations as not deprecated.
 *
 * @discussion This function is important when matching an online database behind an API.
 * If the current class model does NOT have any child entities / relations, then 
 * it is not required to implement it.
 *
 * This function is automatically called after creating an entity with: `createEntityFromDictionary:`.
 * Unless the CREATE method returns `.Delete` the current/new entity will be stored as not deprecated.
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

/**
 * @brief OPTIONAL function to verify the validity of an entity.
 *
 * @discussion During the CRUD process an entity is tested to verify its validity.
 * If nil is returned no `invalidReason` has been found.
 * Otherwise the reason will automatically be used and logged by
 * the function `deleteEntityWithReason:`.
 *
 * Depending on the app and its architecture some entities could get invalid 
 * when something important has been removed or updated.
 * If this required field is verified in this function, the current entity
 * will be, if needed, removed.
 *
 * If the log is activated for the current class, the terminal will display
 * all important modification.
 *
 * @return An invalid reason; nil if valid.
 *
 * Example:
 * If a `book` does not have a `title` anymore your application
 * could not want to display/handle the case. Same if its `pages`
 * are missing.
 * The super function should be called.
 *
 * @code
 * if let invalidReason = super.invalidReason() {
 *   return invalidReason
 * }
 * if self.pages.count == 0 {
 *   return "invalid number of pages to display"
 * }
 * if self.title == nil {
 *   return "invalid book title"
 * }
 * return nil
 */
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

/**
 * @brief REQUIRED function to delete the child entities of a current entity.
 *
 * @discussion To remove an entity one should call `deleteEntityWithReason:`.
 * When doing so the current function is called.
 * The expected behavior is to remove any data store on the disk (like image assets)
 * but also to forward the destruction process to its child entities.
 * The super function should always be called.
 *
 * When implementing a DB that matches a distant database (behind an API) this function
 * might also be called when an entity gets deprecated/disabled.
 *
 * @return nothing
 *
 * Example:
 * If an entity `book` has many entities `pages` as children then a good practice is to do:
 * @code for page in book.pages {
 *   page.deleteEntityWithReason("parent book removed")
 * }
 * AssetManager.removeCachedImage(book.image)
 */
- (void)deleteChildEntities;
- (void)deleteEntityWithReason:(NSString *)reason;
+ (void)deleteAllEntities;
+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array;

@end
