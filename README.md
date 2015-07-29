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

_Example_: `Book.swift` and `Book+DKDBManager.swift`

__warning__ If your code is in Swift you can either generate the NSManagedObject subclasses in _Swift_ or _Obj-C_.

- _Swift_: add `@objc(ClassName)` before the implementation:

		@objc(Book)
		class Book: NSManagedObject {
			@NSManaged var name: NSString?
			@NSManaged var order: NSNumber?
		}

- _Obj-C_: import the class header in the bridge-header file.

		#import "Book.h"

## Simple local database

This part explains how to create and configure a single local database that do not need to be updated from an API.
In this case there is no need of deprecated entities or automatic updates.

As explained earlier, you first need the data inside a NSDictionary object.
This data will get parsed and the library will apply a CRUD logic on it.

In each extented class, implement the following methods:

### Required

[+ primaryPredicateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/primaryPredicateWithDictionary:) to create a predicate used in the CRUD process to find the right entity corresponding to the given dictionary. This function should create and return a `NSPredicate` object that match only one database entity.
If you need more information on how to create a NSPredicate object, please read the [official documentation](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html). 

	override public class func primaryPredicateWithDictionary(dictionary: [NSObject:AnyObject]!) -> NSPredicate! {

		// If returns nil then only ONE entity will ever be created and updated.
		return nil

		// - OR -

		// If returns a `false predicate` then a new entity will always be created.
		return NSPredicate(format: "FALSEPREDICATE")

		// - OR -

		// Otherwise the CRUD process use the entity found by the predicate.
		let bookName = GET_STRING(dictionary, "name")
		return NSPredicate(format: "name ==[c] \(bookName)")
    }

[- updateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/updateWithDictionary:) to update the current entity with a given dictionary.

	override public func updateWithDictionary(dictionary: [NSObject : AnyObject]!) {
        // Update attributes
        self.name 		= GET_STRING(dictionary, "name")
        self.order 		= GET_NUMBER(dictionary, "order")
    }

### Optional

[- description](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/description) to improve how the receiving entity is described/logged.

	override var description: String {
        get {
            return "{  name: \(self.name), order: \(self.order) }"
        }
    }

[+ sortingAttributeName](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/sortingAttributeName) to specify a default order for the [+ all](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/all) and and [+ count](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/count) functions.

    override public class func sortingAttributeName() -> String! {
        return "order"
    }

[+ verbose](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/verbose) to toggle the log for the receiving class.

If this value returns `true` and if the `DKDBManager.verbose == true` then the manager will automatically print the entities for this class during the CRUD process. The number of objects and their _(overriden)_ description will also be logged. Another very handy feature, even the activity around this class model will be printed: *Updating Book { name: LOTR, order: 1 }*

    override public class func verbose() -> Bool {
		return true
    }

## How to CREATE and UPDATE entities

To **create** new entities in the current context you need to have your data inside a NSDictionary object.
And then use one of the following functions:

[+ createEntityFromDictionary:completion:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/createEntityFromDictionary:completion:)

[+ createEntityFromDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/createEntityFromDictionary:)

If you have multiple entities to create inside an array feel free to use:

[+ createEntitiesFromArray:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/createEntitiesFromArray:)

To **update** or **save as not deprecated** just call the same function with the same dictionary.
The most important values are the ones required by the function [primaryPredicateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/primaryPredicateWithDictionary:) to actually let the manager finds the entities again. This function should create and return a `NSPredicate` object that match only one database entity.
The values not used to create the primary predicate could be missing or changed, the valid entity will still be found correctly.

	let bookInfo = ["name":"LOTR", "order":1]
	Book.createEntityFromDictionary(entityInfo) { (newBook, state) -> Void in
		//
		// The CRUDed entity is referenced in the `newBook`.
		// Its actual state is described as follow:
	    switch state {
	    case .Create:	// The book has been created, it's all fresh new.
	    case .Update:	// The book has been updated, its attributes changed.
	    case .Save:		// The book has been saved, nothing happened.
	    case .Delete:	// The book has been removed.
	    }
	}

It is also possible to simply **update** an entity once it is instantiated in your code.
The changes will only be made in the current context. If you want the changes to persist, you need to `save`.

	class ViewController 	: UIViewController {
		var aBook 			: Book?

		func awesomeFunction() {
			// Update the entity.
			self.aBook?.name = "The Hobbit"

			// Save the current context to the persistent store.
			DKDBManager.save()
		}
	}

## How to SAVE the current context

When you are doing modifications on the DB entites, you still need to **save the current context into the persistent store** (aka the sqlite file).

To do so use one of the following methods:

[DKDBManager.save()](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/save)

[DKDBManager.saveToPersistentStoreAndWait()](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/saveToPersistentStoreAndWait)

[DKDBManager.saveToPersistentStoreWithCompletion(void ( ^ ) ( BOOL success , NSError *error ))](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/saveToPersistentStoreWithCompletion:)

Those calls need to be done after creating, deleting or updating entities.
Saving to the persistent store is not an easy task, please try to conserve the CPU usage and call those functions only when necessary.

## How to READ entities
#### With MagicalRecord !

To **read** the entities in the current context you need to fetch them using a `NSPredicate` and `Magical Record`.

Using the various methods of [Magical Record](https://github.com/magicalpanda/MagicalRecord) can seriously help you on your everyday development.
Here is the [official documentation](https://github.com/magicalpanda/MagicalRecord/blob/master/Docs/Fetching-Entities.md).

Here is an example showing how to fetch an array of entities depending on their name:

	class func entityForName(name: String) -> [Book] {
		var predicate = NSPredicate(format: "name == \(name)")
		var entities = Book.MR_findAllSortedBy(Book.sortingAttributeName(), ascending: true, withPredicate: predicate)
		return (entities as? [Book] ?? [])
	}

Note that the call to Book.sortingAttributeName() returns the default sorting attribute previously set.
Instead, you could also provide a specific sorting attribute name (e.g.: "order").

## How to DELETE entities

To **delete** an entity use [- deleteEntityWithReason:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteEntityWithReason:). It will delete the current entity, log the reason (if logging is enabled) and forward the delete process to the child entities using the function [- deleteChildEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteChildEntities) (see _How to deal with child entities_).

	aBook.deleteEntityWithReason("removed by user")

If you want to be more radical and remove all entities for the current class you can use [+ deleteAllEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteAllEntities) or [+ deleteAllEntitiesForClass:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/deleteAllEntitiesForClass:).

	Book.deleteAllEntities()

	// - OR -

	DKDBManager.deleteAllEntitiesForClass(Book)

**Attention**, if you call [+ deleteAllEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/deleteAllEntities) on the DKDBManager all entities for all classes will be deleted.

	DKDBManager.deleteAllEntities()

## How to deal with child entities

#### Create and Update

The recommended logic about child entities is to directly add their information in their parent's data.
Meaning, the NSDictionary object used to create a parent entity should also contains the information to create the child entities.
The function [- updateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/updateWithDictionary:) should be used to forward the CRUD process to the child classes.

	override public func updateWithDictionary(dictionary: [NSObject : AnyObject]!) {
		// Update attributes
		self.name 		= GET_STRING(dictionary, "name")
		self.order 		= GET_NUMBER(dictionary, "order")

		// CRUD child entities
        let array = OBJECT(dictionary, "pages")
        Page.createPagesFromArray(array, book: self)
    }

The relation between a `Book` and a `Page` is a `one-to-many` as a book has many pages and a page has just one book.
The custom function `createPagesFromArray` inserts in the dictionary the parent book entity.

	extension Page {
		class func createPagesFromArray(array: AnyObject?, book: Book?) {
			// CRUD pages
			for dict in (array as? [[NSObject : AnyObject]] ?? [[:]])  {
				var copy = dict
				// Insert the parent book object
				copy["book"] = book
				Page.createEntityFromDictionary(copy) { (entity: AnyObject? , state: DKDBManagedObjectState) -> Void in
					if (entity != nil && book != nil) {
					    switch state {
					    // Remove the page from the parent's 'pages' NSSet.
					    case .Delete:           book?.removePagesObject(entity as? Page)
					    // Add the page into the parent's 'pages' NSSet.
					    case .Create:           book?.addPagesObject(entity as? Page)
					    case .Save, .Update:    break // Do nothing.
					    }
					}
				}
			}
		}
	}

**Warning:** The methods `removePagesObject` and `addPagesObject` exist only if you generated your model classes in _Obj-C_.
If you did it in _Swift_ you need to manually add small functions do `add` and `remove` child entities. 

    func addPage(page: Page) {
        var bookSet = self.mutableSetValueForKey("page")
        bookSet.addObject(page)
        self.pages = bookSet
    }

The CRUD process will then call the following function to update the `Page` entity. Use this one to set the parent book object.

	override public func updateWithDictionary(dictionary: [NSObject : AnyObject]!) {
		// Super update
		super.updateWithDictionary(dictionary)

		// Setup parent Book
		self.book 		= OBJECT(dictionary, "book") as? Book

		// Update attributes
		self.text 		= GET_STRING(dictionary, "text")
	}

#### Save

- (void)saveEntityAsNotDeprecated;

#### Delete

The CRUD process or a specific user action might needs to **delete an entity**.
In most of the case the child entities need to be removed as well.

This _cascade removal_ allows the developer to remove a complete structure of entities in just one single line:

	// Delete a book and all its pages and other child entities
	aBook.deleteWithReason("user does not want it anymore") 

To make sure the `pages` of this deleted `book` are also deleted implement the [- deleteChildEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteChildEntities) function.

	// remove all the child of the current object
    public override func deleteChildEntities() {
        // super call
        super.deleteChildEntities()

        for page in (self.pages as? Set<Page> ?? []) {
			page.deleteEntityWithReason("parent book removed")
        }
    }

## Database matching an API

#### Extended protocol

Implement the following functions inside the NSManagedObject subclasses:

- [- invalidReason](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteIfInvalid)
- [- shouldUpdateEntityWithDictionary](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/shouldUpdateEntityWithDictionary:)

If a class has some child entitites:

- [- saveEntityAsNotDeprecated](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/saveEntityAsNotDeprecated)
- [- deleteChildEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteChildEntities)

For more information, see the **How to deal with child entities** section.

#### Deprecated entities

A deprecated entity is an object not saved as `not deprecated` in the DKDBManager.
TODO: explain more about deprecated entities

To remove the deprecated entities call the function [+ removeDeprecatedEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/removeDeprecatedEntities) after the CRUD process (when refreshing the local database from an API) and before `saving` the current context to the persistent store.

	// CRUD process
	DKDBManager.createEntityFromDictionary(data)

	// Remove all deprecated (not set as 'not deprecated')
	DKDBManager.removeDeprecatedEntities()

	//
	// If some entities are not well integrated/linked to the other ones,
	// they could become invalid after removing the deprecated entities.
	// It is then required do it manually:
	Book.checkAllDeprecatedEntities()

	// Save the current context to the persistent store
	DKDBManager.saveToPersistentStoreWithCompletion() { /* Do something */}

TODO: explain more about .checkAllDeprecatedEntities()

#### Delete if invalid

If the function [invalidReason](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteIfInvalid) has been implemented you can also manually delete invalid entities: [- deleteIfInvalid](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteIfInvalid)

	aBook.deleteIfInvalid()

## Tips

- Add more custom functions inside the helper files. Every logic related to one class model should/could be inside this file. It helps a lot to structure the code. 

- Subclass the DKDBManager and add more DB related functions keeps the app delegate cleaner.

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

