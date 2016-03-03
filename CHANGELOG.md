# DKDBManager CHANGELOG

## 0.6.4

### DKDBManager

- Now check on setup if all non-abstract model class are correctly configured as a custom class.
- Improve log on start: now display the model classes.

## 0.6.3

### DKDBManager

- Add `entityInContext:`function.
- Add `entityInDefaultContext` function.

### NSManagedObjectContext

- By default, `primaryPredicateWithDictionary:` now returns a FALSEPREDICATE. Unless it is overridden, the library will always create a new entity instead of reusing old ones.

## 0.6.2

### DKDBManager

- Add `removeAllStoredIdentifiers` function.
- Add `removeDeprecatedEntitiesInContext:forClass:` function.

## 0.6.1

### DKDBManager

- Add `removeAllStoredIdentifiersForClass:` function.

## 0.6.0

- Rewrite test project in Swift.
- Update Magical Record to 2.3.2 and integration as framework.
- Update global documentation.
- Improve Swift compatibility.

### DKDBManager

- Add `dumpInContext:` function.
- Add `dumpCountInContext:` function.
- Add `cleanUp` function which also removes the stored identifiers.
- Rename `entities` function into `entityClassNames`.
- The `storedIdentifiers` can now be accessed as a property.

#### Simplify setup methods

- Add `setup` and `setupDatabaseWithName:` functions.
- Change `setupDatabaseWithName:didResetDatabase:` function.

#### Save methods with context and block

- Remove `save`, `saveToPersistentStoreAndWait` and `saveToPersistentStoreWithCompletion:` methods.
- Add `saveWithBlock:` function.
- Add `saveWithBlock:completion:` function.
- Add `saveWithBlockAndWait:` function.

- Rename `removeDeprecatedEntities` function into `removeDeprecatedEntitiesInContext:`.
- Rename `deleteAllEntities` function into `deleteAllEntitiesInContext:`.
- Rename `deleteAllEntitiesForClass:` function into `deleteAllEntitiesForClass:inContext:`.

### NSManagedObject Category

#### Create methods with context and block

##### CREATE

- Add `createEntityInContext:`function.
- Update `createEntityFromDictionary:completion:` to `createEntityFromDictionary:inContext:completion:`.
- Update `createEntityFromDictionary:` to `createEntityFromDictionary:inContext:`.
- Update `createEntitiesFromArray:` to `createEntitiesFromArray:inContext:`.

##### READ

- Add `allInContext:` and `countInContext:` functions.

##### UPDATE

- Update `shouldUpdateEntityWithDictionary:` to `shouldUpdateEntityWithDictionary:inContext:`.
- Update `updateWithDictionary:` to `updateWithDictionary:inContext:`.

##### DELETE

- Update `deleteIfInvalid` to `deleteIfInvalidInContext:`.
- Update `deleteAllEntities` to `deleteAllEntitiesInContext:`.
- Update `removeDeprecatedEntitiesFromArray:` to `removeDeprecatedEntitiesFromArray:inContext:`.
- Remove `deleteChildEntities` function. Use `deleteEntityWithReason:inContext:` instead.

### External links

- [Apple official documentation](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/HowManagedObjectsarerelated.html)
- [Magical Record: Working with Managed Object Contexts](https://github.com/magicalpanda/MagicalRecord/wiki/Working-with-Managed-Object-Contexts)

## 0.5.3

- Import Magical Record as framework to support cocoapods 0.39.0

## 0.5.2

- Add documentation.
- Minor parameter renaming `updateWithDictionary:(NSDictionary *)dictionary`.
- Remove DKHelper

## 0.5.1

- Add version requirement on dependencies.

## 0.5.0

- Update to MagicalRecord 2.3.0.
- Functions `saveEntity:` and `save` have been renamed `saveEntityAsNotDeprecated`
- Improve DB LogLevel. The post-install hack in the Podfile is no longer required.
- Abstract models are now ignored by the manager when loging or when searching for deprecated entities.
- Add `deleteIfInvalid` function.

## 0.4.2

- Improve Swift portability

## 0.4.1

- Add getter method for entities in current database
- Add new categorised class to verify an NSManagedObject validity

## 0.4.0

- Update README
- Improve documentation
- Method 'entities' is not required anymore
- Create new delete methods
- The DKManagedObject protocol does not exist anymore
- The setup coredata stack method takes only one argument
- Bug fixes

## 0.3.2

- Minor log improvement

## 0.3.1

- Minor improvement on shouldUpdateEntity method

## 0.3.0

- Add log after a saveToPersistentStoreAndWait call
- New naming: 'shouldUpdateEntity:withDictionary:'
- Minor code logic improvement

## 0.2.1

- remove minor warning

## 0.2.0

- Improve log methods
- Improve entities saving and deprecation removal

## 0.1.2

- Database name bug fix

## 0.1.0

- Missing license fix

## 0.1.0

- Initial release.
