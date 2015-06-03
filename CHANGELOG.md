# DKDBManager CHANGELOG

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
