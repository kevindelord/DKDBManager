//
//  NSManagedObject+DKDBManager.h
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "DKDBManager.h"

#pragma mark - ENUM

/**
 * @typedef DKDBManagedObjectState
 *
 * @brief DBManager state of an entity.
 *
 * @discussion
 * The values of this enum represent whether an entity has been created, updated, saved or deleted.
 *
 * @field .<b>Create</b> The entity has been created, it's all fresh new.
 *
 * @field .<b>Update</b> The entity has been updated, its attributes changed.
 *
 * @field .<b>Save</b>   The entity has been saved, nothing happened.
 *
 * @field .<b>Delete</b> The entity has been removed.
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

#pragma mark - NSManagedObject

/**
 *  Category of the NSManagedObject class.
 *  This adds functions required by the CRUD process.
 *
 *  Please read the README.md for more information.
 */
@interface NSManagedObject (DKDBManager)

#pragma mark - CREATE

/**
 *  @brief CRUD a database entity for the current class model from a NSDictionary object.
 *
 *  @param dictionary The NSDictionary object used to CRUD an entity.
 *
 *  @param context The current saving context.
 *
 *  @param completion A completion block containing the entity and its CRUD state.
 *
 *  @discussion
 *  This function is the most important one in this library.
 *
 *  At first it will try to fetch an entity in the persistent store by using the `primaryPredicateWithDictionary:`.
 *  If the entity does not exist or is not found, a new one will be created.
 *
 *  Then this new object (or the already existing one) will be updated with `updateWithDictionary:`.
 *
 *  If the entity is now invalid it will get deleted; current function returns nil.
 *
 *  In the end, if valid, the current object will get saved as not deprecated by the manager and be returned.
 *
 *  @remark Deleted entities are not returned.
 *
 *  About the status in the completion block:
 *
 *  - .<i>Create</i> if the entity has been created and updated.
 *
 *  - .<i>Update</i> if the entity was already created and has just been updated.
 *
 *  - .<i>Save</i> if the entity was already created and nothing changed.
 *
 *  - .<i>Delete</i> if the entity has been deleted.
 *
 *  @see typedef DKDBManagedObjectState
 *  @see + (NSPredicate *)primaryPredicateWithDictionary:;
 *  @see - (BOOL)shouldUpdateEntityWithDictionary:;
 *  @see - (NSString *)invalidReason;
 *  @see - (void)saveEntityAsNotDeprecated;
 *
 *  @return A created/read/updated database entity; nil if deleted.
 */
+ (instancetype _Nullable)createEntityFromDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext completion:(void (^ _Nullable)(id _Nullable entity, DKDBManagedObjectState status))completion;

/**
 *  @brief CRUD a database entity for the current class model from a NSDictionary object.
 *
 *  @param dictionary The NSDictionary object used to CRUD an entity.
 *
 *  @param context The current saving context.
 *
 *  @see + (instancetype)createEntityFromDictionary:inContext:completion:;
 *
 *  @return A created/read/updated database entity.
 */
+ (instancetype _Nullable)createEntityFromDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext;

/**
 *  @brief CRUD an empty database entity for the current class model.
 *
 *  @discussion The function will use an empty dictionary to create the entity. The usual CRUD process will be used.
 *
 *  @param context The current saving context.
 *
 *  @see + (instancetype)createEntityFromDictionary:inContext:completion:;
 *
 *  @return A created/read/updated database entity.
 */
+ (instancetype _Nullable)createEntityInContext:(NSManagedObjectContext * _Nonnull)savingContext;

/**
 *  @brief CRUD database entities for the current class model from an array of NSDictionary objects.
 *
 *  @param array The NSArray object containing all the NSDictionary objects to CRUD the entities from.
 *
 *  @param context The current saving context.
 *
 *  @see + (instancetype)createEntityFromDictionary:inContext:completion:;
 *
 *  @return An array of created/read/updated database entities.
 */
+ (NSArray * _Nullable)createEntitiesFromArray:(NSArray * _Nonnull)array inContext:(NSManagedObjectContext * _Nonnull)savingContext;

#pragma mark - SAVE

/**
 *  @brief Function automatically called by the CRUD process logs the status and calls the `saveEntityAsNotDeprecated` function.
 *
 *  @remark Does not save as not deprecated in case of `.Delete` status.
 *
 *  @param entity A created/read/updated database entity; nil if deleted.
 *
 *  @param status The CRUD status of the entity.
 *
 *  @see + (instancetype)createEntityFromDictionary:inContext:completion:;
 *
 *  @see - (void)saveEntityAsNotDeprecated;
 *
 *  @return A saved or deleted database entity.
 */
+ (instancetype _Nullable)saveEntityAfterCreation:(id _Nullable)entity status:(DKDBManagedObjectState)status;

/**
 *  @brief Override this function to store the current object and all its child relations as not deprecated.
 *
 *  @discussion This function is important when matching an online database behind an API.
 *
 *  Override required if the current class model has some child entities (relationships).
 *
 *  This function is automatically called after '<i>CRUD</i>ing' an entity with: `createEntityFromDictionary:inContext`.
 *
 *  Unless the method returns `.Delete` the current/new entity will be stored as not deprecated.
 *
 *  @remark The `super` function must be called and the process forwarded to all child entities.
 *
 *  For example, an entity `book` with many child entities `pages`.
 *
 *  @code
 *  public override func saveEntityAsNotDeprecated() {
 *      super.saveEntityAsNotDeprecated()
 *      for page in book.pages {
 *          page.saveEntityAsNotDeprecated()
 *      }
 *  }
 *  @endcode
 *
 *  @remark When the entity is created but its child can not be at the same time, then the developper has to create another function and manually save the objects when they have been checked/created.
 *
 *  In few words, when an <i>empty</i> `book` is created/updated and its `pages` some time later; the <i>save as not deprecated</i> must be done manually for the `pages`.
 *
 *  On the second app start, the CRUD process will mark the existing `book` as not deprecated.
 *  The `pages` will not be marked until the second custom function is called.
 */
- (void)saveEntityAsNotDeprecated;

#pragma mark - READ

/**
 *  @brief Override this function to return a custom unique identifier of the current entity.
 *
 *  @discussion When using the DKDBManager to match a distant database (behind an API) the logic to remove deprecated objects uses an `uniqueIdentifier` for every class.
 *
 *  The identifer of each entity is saved when '<i>CRUD</i>ing' the entities.
 *  It is used when the function `removeDeprecatedEntitiesInContext:` is called.
 *
 *  The default value use the native `objectID` property of a NSManagedObject.
 *
 *  Override this method to use a custom unique identifer built from a class attribute or anything else.
 *
 *  @return The unique identifer of the current model entity.
 */
- (id _Nonnull)uniqueIdentifier;

/**
 * @brief Override this function to verify the validity of an entity; default returns nil.
 *
 * @discussion During the CRUD process an entity is tested to verify its validity.
 * If `nil` is returned no `invalidReason` has been found.
 * Otherwise the reason will automatically be used and logged by
 * the function `deleteEntityWithReason:inContext:`.
 *
 * Depending on the app and its architecture some entities could become invalid
 * when something important has been removed or updated. This function is called to verify that.
 *
 * If the log is activated for the current class, the terminal will display
 * all important modification.
 *
 * The super function should be called.
 *
 * For example, if a `book` does not have a `title` anymore your application
 * could not want to display/handle the case. Same if its `pages` are missing.
 *
 * @code
 * override public func invalidReason() -> String? {
 *     if let invalidReason = super.invalidReason() {
 *         return invalidReason
 *     }
 *     if (self.pages.count == 0) {
 *         return "invalid number of pages to display"
 *     }
 *     if (self.title == nil) {
 *         return "invalid book title"
 *     }
 *     return nil // the entity is valid
 * }
 * @endcode
 *
 * @return An invalid reason; nil if valid.
 */
- (NSString * _Nullable)invalidReason;

/**
 *  @brief Override this function to inform the manager whether it should update the current entity or not.
 *
 *  @param dictionary A NSDictionary object containing information about the database entity to be updated with.
 *
 *  @param context The current saving context.
 *
 *  @discussion Depending on your app and architecture some entities should not be updated or do not need to. This function allows you to check that and avoid useless updates during the CRUD process.
 *
 *  For example you might want to verify the `lastUpdate` attribute or a version number from the given dictionary against the current entity.
 *  If they match then return `false` to NOT update the entity and avoid some useless actions.
 *
 *  @remark The result of this function is ignored when the debug states of the manager are set as `needForcedUpdate == true` or if `allowUpdate == false`.
 *
 *  @return TRUE if the entity should be updated by the manager; default is TRUE.
 */
 - (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext;

/**
 *  @brief Override this function to enable all activitiy logs about the current class entity or not.
 *
 *  @return TRUE if log is activated; default is FALSE.
 */
 + (BOOL)verbose;

/**
 *  @brief Override this function to set a default sorting key for the current class entity.
 *
 *  @return Sorting key as a NSString object; default is nil.
 */
 + (NSString * _Nullable)sortingAttributeName;

/**
 *  @brief Override this function to create a predicate used in the CRUD process to find the right entity corresponding to the given dictionary.
 *
 *  @param dictionary A NSDictionary object containing information about the database entity to be fetched with.
 *
 *  @discussion The predicate returned is used in the CRUD process to fetch an entity from the database. Depending on the returned value the manager will create a new entity, update or delete an existing one.
 *
 *  The predicate should be created depending on the given parameter `dictionary`.
 *
 *  If the current function returns:
 *
 *  - <i>valid predicate</i>: If existing, the entity found will be used in the CRUD process.
 *
 *  - <i>nil</i>: The CRUD process will only take the first entity created (if any) and update it. By doing so only ONE entity will ever be created.
 *
 *  - <i>false predicate</i>: The CRUD process will always create a new entity.
 *
 *  - <i>true predicate</i>: The CRUD process will use a random entity in the database. Should not be used.
 *
 *  For example, your entity `Book` could be fetch through its `releaseDate` and `title` attributes.
 *
 *  Default: Returns a `false predicate`.
 *
 *  @see + (instancetype)createEntityFromDictionary:inContext:completion:;
 *
 *  @return A NSPredicate object to find/fetch an entity in the local database.
 */
 + (NSPredicate * _Nullable)primaryPredicateWithDictionary:(NSDictionary * _Nullable)dictionary;

/**
 *  @brief Returns all entities of the current class model within a specific context.
 *
 *  @discussion The values are sorted by the default sorting attribute.
 *
 *  @param context The context from where all entities will be fetched.
 *
 *  @see + (NSString *)sortingAttributeName;
 *
 *  @return A NSArray object containing all entities from the current class model.
 */
+ (NSArray * _Nullable)allInContext:(NSManagedObjectContext * _Nonnull)context;

/**
 *  @brief Returns all entities of the current class model using the default NSManagedObjectContext object.
 *
 *  @discussion This method uses a NSManagedObjectContext object operating on the main thread (simple and single-threaded operations only).
 *
 *  @see + (NSString *)sortingAttributeName;
 *
 *  @return A NSArray object containing all entities from the current class model.
 */
+ (NSArray * _Nullable)all;

/**
 *  @brief Count all entities of the current class model within a specific context.
 *
 *  @param context The context from where all entities will be counted.
 *
 *  @return A NSInteger value corresponding to the total number of entities of the current class model.
 */
+ (NSInteger)countInContext:(NSManagedObjectContext * _Nonnull)context;

/**
 *  @brief Count all entities of the current class model using the default NSManagedObjectContext object.
 *
 *  @discussion This method uses a NSManagedObjectContext object operating on the main thread (simple and single-threaded operations only).
 *
 *  @return A NSInteger value corresponding to the total number of entities of the current class model.
 */
+ (NSInteger)count;

/**
 *  @brief Fetch the current entity from the given database context.
 *
 *  @param context The context from where the entity will be retrieve.
 *
 *  @return The fetched database entity if found; nil otherwise.
 */
- (instancetype _Nullable)entityInContext:(NSManagedObjectContext * _Nonnull)context;

/**
 *  @brief Fetch the current entity from the current database context.
 *
 *  @dicussion This funciton will use the default NSManagedObjectContext object.
 *
 *  @return The fetched database entity if found; nil otherwise.
 */
- (instancetype _Nullable)entityInDefaultContext;

#pragma mark - UPDATE

/**
 *  @brief Override to update the current entity with a given dictionary.
 *
 *  @param dictionary A NSDictionary object containing new information about the database entity.
 *
 *  @param context The current saving context.
 *
 *  @discussion Use this function and the given parameter to update the attributes of the current entity.
 *
 *  Depending on your project and architecture the information/data of the child entities could be inside the dictionary.
 *  In this case initiate the CRUD process from this function.
 *
 * 	@remark The super function should be called.
 *
 *  For example, a `Book` entity could have some `Images` as child entities.
 *  @code
 *  override func updateWithDictionary(dictionary: [NSObject : AnyObject]?, inContext savingContext: NSManagedObjectContext) {
 *      super.updateWithDictionary(dictionary)
 *      self.id = GET_NUMBER(dictionary, "id")
 *      self.title = GET_STRING(dictionary, "title")
 *      // child entities
 *      self.images = Images.createEntitiesFromArray(GET_ARRAY(dictionary, "images"))
 *  }
 *  @endcode
 */
- (void)updateWithDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext;

#pragma mark - DELETE

/**
 *  @brief Check and delete the current entity if invalid within a given context.
 *
 *  @discussion This function verifies the validity of the current entity with the function `invalidReason`.
 *
 *  @param context The current saving context.
 *
 *  @see - (NSString *)invalidReason;
 *
 *  @return TRUE is the entity has been deleted; otherwise FALSE.
 */
- (BOOL)deleteIfInvalidInContext:(NSManagedObjectContext * _Nonnull)savingContext;

/**
 *  @brief Override this function to delete the child entities of a current entity within a given context.
 *
 *  @param reason A NSString object explaining why the entity is getting removed from the local database.
 *
 *  @param context The current saving context.
 *
 *  @remark The reason will be logged only if the `verbose` function returns TRUE for the current class model.
 *
 *  @discussion This function is called from the CRUD process when deleting deprecated entities.
 *
 *  The expected behavior is to remove any data stored on the disk (like image assets) <b>and</b> to forward the destruction process to its child entities.
 *
 *  @remark The super function should be called after removing child and local entitities.
 *
 *  For example, an entity `book` has a cover picture and many `pages` entities:
 *
 *  @code
 *  override func deleteEntityWithReason(reason: String?, inContext savingContext: NSManagedObjectContext) {
 *
 *      // Remove cover picture
 *      AssetManager.removeCachedImage(self.coverPicture)
 *      // Forward the destruction process and its reason to every child entities.
 *      for page in self.pages {
 *          page.deleteEntityWithReason("parent book removed", inContext: savingContext)
 *      }
 *      // Call the super function
 *      super.deleteEntityWithReason(reason, inContext: savingContext)
 *  }
 *  @endcode
 *
 *  @see + (BOOL)verbose;
 */
- (void)deleteEntityWithReason:(NSString * _Nullable)reason inContext:(NSManagedObjectContext * _Nonnull)savingContext;

/**
 * @brief Delete all entities from the current class model within a given context.
 *
 * @discussion All entites for the current class model will be removed.
 *
 * @remark The function `deleteEntityWithReason:inContext:` will NOT be called.
 *
 * @param context The current saving context.
 */
+ (void)deleteAllEntitiesInContext:(NSManagedObjectContext * _Nonnull)savingContext;

/**
 * @brief Check and remove all deprecated entities from the local database within a given context.
 *
 * @discussion The entities are automatically set as not deprecated in the CRUD process.
 * The ones that are not set will then disappear from the local store.
 *
 * Theoretically the entities present in the given array are marked as not depecrated and will not be removed.
 *
 * @param array A NSArray object containing all not deprecated entities for the current class model.
 *
 * @param context The current saving context.
 *
 * @see - (void)saveEntityAsNotDeprecated;
 */
+ (void)removeDeprecatedEntitiesFromArray:(NSArray * _Nonnull)array inContext:(NSManagedObjectContext * _Nonnull)savingContext;

@end

#pragma mark - Log

/**
 *  @brief Log a string if the verbose boolean is enabled.
 *
 *  @param logEnabled Boolean to enable or not the log.
 *  @param format     Format of the NSString
 *  @param ...        Var args
 */
void CRUDLog(BOOL logEnabled, NSString * _Nonnull format, ...);
