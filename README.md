# DKDBManager

[![Version](https://img.shields.io/cocoapods/v/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![License](https://img.shields.io/cocoapods/l/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Platform](https://img.shields.io/cocoapods/p/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)

## Concept

DKDBManager is a simple, yet very useful, CRUD manager around [Magical Record](https://github.com/magicalpanda/MagicalRecord) (a wonderful CoreData wrapper). The current library will implement a logic around it and helps the developer to manage his entities.

Through the implemented *CRUD* logic you will be able to focus on other things than the “classic” repetitive and boring data management.

The main concept is to use JSON dictionaries representing your entities. The logic to create, read or update your entities is done with just one single function. The delete logic has also been improved with a `deprecated` state.

## Documentation

The complete documentation is available on [CocoaDocs](http://cocoadocs.org/docsets/DKDBManager).

More over, the [Wiki](https://github.com/kevindelord/DKDBManager/wiki) contains all kind of information and details the different logics of the library.

- [Setup](https://github.com/kevindelord/dkdbmanager/wiki#setup)
- [Configuration](https://github.com/kevindelord/dkdbmanager/wiki#configuration)
- [Simple Local Database](https://github.com/kevindelord/dkdbmanager/wiki#simple-local-database)
- [Matching a JSON](https://github.com/kevindelord/dkdbmanager/wiki#matching-a-json)
- [Database matching an API](https://github.com/kevindelord/dkdbmanager/wiki#database-matching-an-api)
- [Other Resources](https://github.com/kevindelord/dkdbmanager/wiki#other-resources)

## Try it!

Checkout the example project:

	`pod try DKDBManager`

## Author

kevindelord, delord.kevin@gmail.com
