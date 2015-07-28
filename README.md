# DKDBManager

[![Version](https://img.shields.io/cocoapods/v/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![License](https://img.shields.io/cocoapods/l/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Platform](https://img.shields.io/cocoapods/p/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)

## Concept

DKDBManager is simple, yet very useful, CRUD manager around [Magical Record](https://github.com/magicalpanda/MagicalRecord) (a wonderful CoreData wrapper). The current library will implement a logic around it and helps the developer to manage his entities.

Through the implemented *CRUD* logic you will be able to focus on other things than the classic-repetitivly boring data management.

The main concept is to use JSON dictionaries representing your entities. The logic to create, read or update your entities are done with just one single function. The delete logic has also been improved with a `deprecated` state.

Extend the NSManagedObject subclasses is required.

## Documentation

The complete documentation is available on [CocoaDocs](http://cocoadocs.org/docsets/DKDBManager).

The library is explained using Swift code. For an Obj-C example see the sample projects.

## Installation

DKDBManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DKDBManager"

and run `pod install` from the main directory.

## Getting Started

To get started, first, import the header file DKDBManager.h in your project's .pch or bridge-header file. This will import in your project all required headers for `Magical Record` and CoredData`.

    #import "DKDBManager.h"

As the `DKDBManager` is a light wrapper around [Magical Record](https://github.com/magicalpanda/MagicalRecord) you first need to implement minor methods within your AppDelegate. Afterwhat you still have to generate your model classes and create categories (or extensions in Swift).

### AppDelegate using DKDBManager

First you need to setup the CoreData stack with a specifc file name. Of course you can play with the name to change your database on startup whenever you would like to.
A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions` method of your `AppDelegate`.
You could also sublclass the DKDBManager and wrap the following in a dedicated class. 

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		var didResetDB = DKDBManager.setupDatabaseWithName("DKDatabaseName.sqlite")
		if (didResetDB) {
			// The database is fresh new.
			// Depending on your needs you might want to do something special right now as:.
			// - Setting up some user defaults.
			// - Deal with your api/store manager.
			// etc.
        }
        // Starting this point your database is ready to use.
		// You can now create any object you could need.

        return true
	}

	func applicationWillTerminate(application: UIApplication) {
		DKDBManager.cleanUp()
	}

### Configuration

You can configure how the manager will react on execution. Add the following **optional** lines before calling `setupDatabaseWithName:`:

[+ verbose](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/verbose) to toggle the log.

	DKDBManager.setVerbose(true)

[+ allowUpdate](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/allowUpdate) to allow the manager to update the entities when parsing new data.

	DKDBManager.setAllowUpdate(true)

[+ resetStoredEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/resetStoredEntities) to completely reset the database on startup.
Instead of removing your app from the simulator just activate this flag and the local DB will be brand new when your app starts.

	DKDBManager.setResetStoredEntities(false)

[+ needForcedUpdate](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/needForcedUpdate) to force the manager to update the entities during the CRUD process.

    DKDBManager.setNeedForcedUpdate(false)

### Models Configuration

The models configuration is done as in any other projects.

First create and configure your model entities inside the `.xcdatamodel` file.
Then generate with Xcode the NSManagedObject subclasses as you are used to.

After that, create category files (or extensions in Swift) for each model.
The functions and logic will be implemented in those files. If it was done in the generated files, your changes would be removed everytime you generate them again.

_Example_: `DBEntity.swift` and `DBEntity+DKDBManager.swift`

__warning__ If your code is in Swift you can either generate the NSManagedObject subclasses in _Swift_ or _Obj-C_.

- _Swift_: add `@objc(ClassName)` before the implementation:

		@objc(Entity)
		class Entity: NSManagedObject {
			@NSManaged var name: NSString?
			@NSManaged var order: NSNumber?
		}

- _Obj-C_: import the class header in the bridge-header file.

		#import "Entity.h"

## Simple local database

This part explains how to create and configure a single local database that do not need to be updated from an API.
In this case there is no need of deprecated entities or automatic updates.

As explained earlier, you first need the data inside a NSDictionary object.
This data will get parsed and the library will apply a CRUD logic on it.

In each extented class the following methods are **required**:

[+ primaryPredicateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/primaryPredicateWithDictionary:) to create a predicate used in the CRUD process to find the right entity corresponding to the given dictionary.

	+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary {
		// If returns nil then only ONE entity will ever be created and updated.
		// If returns a `false predicate` then a new entity will always be created.
		// Otherwise the CRUD process use the entity found by the predicate.
		return NSPredicate(format: "FALSEPREDICATE");
	}

[- updateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/updateWithDictionary:) to update the current entity with a given dictionary.

	override public func updateWithDictionary(dictionary: [NSObject : AnyObject]!) {
        // Update attributes
        self.name 		= GET_STRING(dictionary, "name")
        self.order 		= GET_NUMBER(dictionary, "order")
    }

The following **optional** ones are also recommended:

[- description](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/description) to improve how the receiving entity is described/logged.

	override var description: String {
        get {
            return "\(self.order) : \(self.name)"
        }
    }

[+ sortingAttributeName](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/sortingAttributeName) to specify a default order for the [+ all](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/all) and and [+ count](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/count) functions.

    override public class func sortingAttributeName() -> String! {
        return "order"
    }

[+ verbose](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/verbose) to toggle the log for the receiving class.

    override public class func verbose() -> Bool {
		return true
    }

## Database matching API

To implement:

invalidReason
saveEntityAsNotDeprecated
deleteChildEntities
shouldUpdateEntityWithDictionary

To call:

DKDBManager.removeDeprecatedEntities()
//
// As the recipes are not directly integrated within the books,
// they could become invalid after removing the deprecated entities.
// See Book+Helper for me information.
Book.checkAllDeprecatedEntities()

## How to create entities

-> Always same bookInfo?
Book.createEntityFromDictionary(bookInfo) { (newBook, state) -> Void in
    //
    // Depending on what change on the DB fetch the recipes or not.
    // If the state is `.Create` or `.Update` the recipes SHOULD be refreshed. (Fetch recipes for book.)
    // If the state is `.Save` nothing changed. The entity is automatically marked as not-deprecated.
    //      BUT as the recipes are not directly integrated within the books but separately
    //      it is necessary to manually save the child entities.
    // If the state is `.Delete` the entity as been removed; newBook = nil.
    //
    // Reduce the ready counter only for `.Delete` and `.Save` as the function `fetchRecipesForBook:`
    // calls it for the other two states when all recipes have been saved or updated.
    //
    switch state {
    case .Save:
        (newBook as? Book)?.saveChildEntitiesAsNotDeprecated()
        self.reduceReadyCount(completionBlock)
    case .Delete:
        self.reduceReadyCount(completionBlock)
    case .Create, .Update:
        (newBook as? Book)?.preloadImages()
        self.fetchRecipesForBook(newBook as? Book, receipt: IAPManager.currentReceipt(), completionBlock: completionBlock)
    }
}

then 

DKDBManager.save()
DKDBManager.saveToPersistentStoreAndWait()
DKDBManager.saveToPersistentStoreWithCompletion { (succeed, error) -> Void in
	completionBlock()
}


## MagicalRecord request

create predicate and use default function
example:
    func sortedNotes() -> [Note]? {
        var predicate = NSPredicate(format: "\(DB.Key.Recipe).\(DB.Key.Id) ==[c] \(self.id)")
        var notes = Note.MR_findAllSortedBy(Note.sortingAttributeName(), ascending: true, withPredicate: predicate)
        return notes as? [Note]
    }

Add link to official documentation.

## Projects

`DKDBManager` is used in the following projects:

- WhiteWall
- Pons-SprachKalender
- Pons-Bildwoerterbuch
- ERGO ZahnPlan
- Handhelp
- RezeptBOX
- Huethig
- Digster Music Deals
- *Your project here*

## TODO

- Improve documentation
- Add tests
- Add project links

## Author

kevindelord, delord.kevin@gmail.com

## License

DKDBManager is available under the MIT license. See the LICENSE file for more info.

