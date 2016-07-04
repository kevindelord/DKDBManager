# DKDBManager

[![Build Status](https://travis-ci.org/kevindelord/DKDBManager.svg?branch=master)](https://travis-ci.org/kevindelord/DKDBManager)
[![codecov.io](https://codecov.io/github/kevindelord/DKDBManager/coverage.svg?branch=master)](https://codecov.io/gh/kevindelord/DKDBManager)
[![Cocoapods](https://img.shields.io/cocoapods/v/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/kevindelord/DKDBManager)
[![License](https://img.shields.io/cocoapods/l/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Platform](https://img.shields.io/cocoapods/p/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)

## Concept

DKDBManager is a simple, yet very useful, CRUD manager around [Magical Record](https://github.com/magicalpanda/MagicalRecord).

It implements a logic around the database that helps the developer to manage his entities and let him focus on other things than only data management.

The main concept is to import JSON dictionaries representing entities into the database.

After some configuration on your model classes, only one single function is needed to _create_, _read_, _update_ or _delete_ your entities!

## Documentation

The complete documentation is available on [CocoaDocs](http://cocoadocs.org/docsets/DKDBManager).

More over, the [Wiki](https://github.com/kevindelord/DKDBManager/wiki) contains all kind of information and details about the different logics of the library.

- [Setup](https://github.com/kevindelord/dkdbmanager/wiki#setup)
- [Configuration](https://github.com/kevindelord/dkdbmanager/wiki#configuration)
- [Simple Local Database](https://github.com/kevindelord/dkdbmanager/wiki#simple-local-database)
- [Matching a JSON](https://github.com/kevindelord/dkdbmanager/wiki#matching-a-json)
- [Database matching an API](https://github.com/kevindelord/dkdbmanager/wiki#database-matching-an-api)
- [Other Resources](https://github.com/kevindelord/dkdbmanager/wiki#other-resources)

## Quick overview

With the `DKDBManager` and `MagicalRecord` you can easily create, update or delete entities.

To do so you need to _be_ in a savingContext and use the appropriate DKDBManager functions:

	DKDBManager.saveWithBlock { (savingContext: NSManagedObjectContext) in

        // Perform saving code here, against the `savingContext` instance.
        // Everything done in this block will occur on a background thread.

		let plane = Plane.crudEntityInContext(savingContext)
		plane?.origin = "London"
        plane?.destination = "Paris"
	}

At the end of this execution block, all changes will be saved ( or _merged_ ) into the default context.

After that, a new `Plane` entity will be available on the main thread within the default context.

Or you could _CRUD_ an entity by using a JSON structure:

	let planeJSON = ["origin":"Paris", "destination":"London"]
	Plane.crudEntityWithDictionary(planeJSON, inContext: savingContext, completion: { (entity: AnyObject?, state: DKDBManagedObjectState) in

		// The CRUDed plane is referenced in the `entity`.
		// Its actual state is described as follow:
		switch state {
		case .Create:	// The entity has been created, it's all fresh new.
		case .Update:	// The entity has been updated, its attributes changed.
		case .Save:		// The entity has been saved, nothing happened.
		case .Delete:	// The entity has been removed.
		}
	})


The `state` variable describes what happened to the entity.

Read more in the [Wiki](https://github.com/kevindelord/DKDBManager/wiki)! :bowtie:

## Try it out!

Checkout the example project:

	$> pod try DKDBManager

## Author

kevindelord, delord.kevin@gmail.com
