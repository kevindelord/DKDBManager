//
//  NSManagedObject+DKDBManager.h
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "DKDBManager.h"

/**
 * @typedef DKDBManagedObjectState
 *
 * @brief DBManager state of an entity.
 *
 * @discussion
 * The values of this enum represent whether an entity has been created, updated, saved or deleted.
 *
 * @field .Create The entity has been created, it's all fresh new.
 *
 * @field .Update The entity has been updated, its attributes changed.
 *
 * @field .Save   The entity has been saved, nothing happened.
 *
 * @field .Delete The entity has been removed.
 */
typedef NS_ENUM(NSInteger, DKDBManagedObjectState) {
    /** The entity has been created, it's all fresh new. */
    DKDBManagedObjectStateCreate,
    /** The entity has been updated, its attributes changed. */
    DKDBManagedObjectStateUpdate,
    /** The entity has been saved, nothing happened. */
    DKDBManagedObjectStateSave,
    /** The entity has been removed. */
    DKDBManagedObjectStateDelete,
} ;

@interface NSManagedObject (DKDBManager)

#pragma mark - CREATE

/**
 * @brief CRUD a database entity for the current class model from a NSDictionary object.
 *
 * @param dictionary The NSDictionary object used to CRUD an entity.
 *
 * @param completion A completion block containing the entity and its CRUD state.
 *
 * @discussion
 * This function is the most important one in this library.
 *
 * At first it will try to fetch
 * an entity in the persistent store by using the `primaryPredicateWithDictionary:`.
 * If the entity does not exist/isn't found, a new one will be created.
 * @see + (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary;
 *
 * Then this new object (or the already existing one) will be updated with `updateWithDictionary:`.
 * @see - (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary *)dictionary;
 *
 * If the entity is now invalid it will get deleted; function returns nil.
 * @see - (NSString *)invalidReason;
 *
 * In the end the current object will get saved as not deprecated by the manager and returned.
 * @see - (void)saveEntityAsNotDeprecated
 *
 * About the status in the completion block:
 *
 * .Create if the entity has been created and updated.
 *
 * .Update if the entity was already created and has just been updated.
 *
 * .Save if the entity was already created and nothing changed.
 *
 * .Delete if the entity has been deleted.
 * @see typedef DKDBManagedObjectState
 *
 * @return A created/read/updated database entity; nil if deleted.
 */
+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion;

/**
 * @brief CRUD a database entity for the current class model from a NSDictionary object. 
 *
 * @param dictionary The NSDictionary object used to CRUD an entity.
 *
 * @discussion The deleted entities are not returned.
 *
 * @see + (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion;
 *
 * @return A created/read/updated database entitiy.
 */
+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary;

/**
 * @brief CRUD database entities for the current class model from an array of NSDictionary objects.
 *
 * @param array The NSArray object containing all the NSDictionary objects to CRUD the entities from.
 *
 * @discussion The deleted entities are not returned.
 *
 * @see + (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion;
 *
 * @return An array of created/read/updated database entities.
 */
+ (NSArray *)createEntitiesFromArray:(NSArray *)array;

#pragma mark - READ

/**
 * @brief Override this function to return a custom unique identifier of the current entity.
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
 * @brief Override this function to store the current object and all its child relations as not deprecated.
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
 *
 * In few words, call this second function when the `pages` of a `book` has been created.
 * On the second start, when the `book` did not get updated it will got saved with `saveEntityAsNotDeprecated`.
 * The `pages` won't be saved until the second custom function is called.
 *
 * The super function should be called.
 *
 * For example, an entity `book` with many child entities `pages`.
 *
 * @code
 * super.saveEntityAsNotDeprecated()
 * for page in book.pages {
 *   page.saveEntityAsNotDeprecated()
 * }
 * @endcode
 */
- (void)saveEntityAsNotDeprecated;

/**
 * @brief Override this function to verify the validity of an entity; default returns nil.
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
 *
 * The super function should be called.
 *
 * For example, if a `book` does not have a `title` anymore your application
 * could not want to display/handle the case. Same if its `pages` are missing.
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
 * @endcode
 *
 * @return An invalid reason; nil if valid.
 */
- (NSString *)invalidReason;

/**
 * @brief Override this function to inform the manager whether it should update the current entity or not.
 *
 * @param dictionary A NSDictionary object containing information about the database entity to be updated with.
 *
 * @discussion Depending on your app and architecture some entities should not be updated or do not need to.
 * This function allows you to check that and avoid the update of the current entity during the CRUD process.
 *
 * For example you might want to verify the `lastUpdate` attribute or a version number from the given dictionary against the current entity.
 * If they match return then `false` to NOT update the entity and avoid some useless actions.
 *
 * The result of this function is ignored when the debug states of the manager are set as
 * `needForcedUpdate == true` or if `allowUpdate == false`.
 *
 * @return TRUE if the entity should be updated by the manager; default is TRUE.
 */
 - (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary *)dictionary;

/**
 * @brief Override this function to enable all activitiy logs about the current class entity or not.
 *
 * @return TRUE if log activated; default is FALSE.
 */
 + (BOOL)verbose;

/**
 * @brief Override this function to set a default sorting key for the current class entity.
 *
 * @return Sorting key as a NSString object; default is nil.
 */
 + (NSString *)sortingAttributeName;

/**
 * @brief Override this function to create a predicate that will find the right entity corresponding to the given dictionary.
 *
 * @param dictionary A NSDictionary object containing information about the database entity to fetched with.
 *
 * @discussion This function is called during the CRUD process to fetch an entity from the database.
 * Depending on the returned predicate the manager will update an existing entity or will create a new one.
 *
 * If returns nil then will only take the first entity created (if any) and update it. By doing so only ONE entity will ever be created.`
 *
 * If returns a `false predicate` then a new entity will always be created.
 *
 * Otherwise use the entity found by the predicate.
 * The predicate should be created depending on the parameter: `dictionary`.
 *
 * For example, your entity `Book` could be fetch through its `releaseDate` and `title` attributes.
 *
 * @return A NSPredicate object to find/fetch an entity in the local database.
 */
 + (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary;

/**
 * @brief Returns all entities of the current class model.
 *
 * @discussion The values are sorted by the default sorting attribute.
 *
 * @see + (NSString *)sortingAttributeName;
 *
 * @return A NSArray object containing all entities from the current class model.
 */
+ (NSArray *)all;

/**
 * @brief Count all entities of the current class model.
 *
 * @return A NSInteger value corresponding to the total number of entities of the current class model.
 */
 + (NSInteger)count;

#pragma mark - UPDATE

/**
 * @brief Override to update the current entity with a given dictionary.
 *
 * @param dictionary A NSDictionary object containing information about the database entity to fetched with.
 *
 * @discussion Use this function and the given parameter to update the attributes of the current entity.
 *
 * Depending on your project and architecture the information/data of the child entities could be inside the dictionary.
 * In this case initiate the CRUD process from this function.
 *
 * The super function should be called.
 *
 * For example, a `Book` entity could have some `Images` as child entities.
 * @code
 * super.updateWithDictionary(dictionary)
 * self.id = GET_NUMBER(dict, "id")
 * self.title = GET_STRING(dict, "title")
 * // child entities
 * self.images = Images.createEntitiesFromArray(GET_ARRAY(dict, "images"))
 * @endcode
 */
- (void)updateWithDictionary:(NSDictionary *)dictionary;

#pragma mark - DELETE

- (BOOL)deleteIfInvalid;

/**
 * @brief Override this function to delete the child entities of a current entity.
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
 * The super function should be called.
 *
 * For example, an entity `book` has many entities `pages` as children then a good practice is to do:
 * @code
 * super.deleteChildEntities()
 * for page in book.pages {
 *   page.deleteEntityWithReason("parent book removed")
 * }
 * AssetManager.removeCachedImage(book.image)
 * @endcode
 */
- (void)deleteChildEntities;

/**
 * @brief Delete the current entity and log the reason.
 *
 * @param reason A NSString object explaining why the entity is getting removed from the local database.
 *
 * @discussion The reason will be logged only if the function `verbose:` returns TRUE for the current class model
 *
 * This function also calls the function `deleteChildEntities` for the current entity.
 *
 * @see - (void)deleteChildEntities;
 * @see + (BOOL)verbose;
 */
- (void)deleteEntityWithReason:(NSString *)reason;

/**
 * @brief Delete all entities from the current class model.
 *
 * @discussion All entites for the current class model will be removed.
 * Functions `deleteChildEntities` or `deleteEntityWithReason:` will not be called.
 */
+ (void)deleteAllEntities;

/**
 * @brief Check and remove all deprecated entities from the local database.
 *
 * @param array A NSArray object containing all not deprecated entities for the current class model.
 *
 * @discussion The entities are automatically set as not deprecated in the CRUD process.
 * The ones that are not refreshed/saved before removing all deprecated entities will then disappear from the local store.
 *
 * @see - (void)saveEntityAsNotDeprecated;
 */
+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array;

@end
