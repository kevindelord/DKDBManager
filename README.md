# DKDBManager

[![Version](https://img.shields.io/cocoapods/v/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![License](https://img.shields.io/cocoapods/l/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Platform](https://img.shields.io/cocoapods/p/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)

## Concept

DKDBManager is a simple, yet very useful, CRUD manager around [Magical Record](https://github.com/magicalpanda/MagicalRecord) (a wonderful CoreData wrapper). The current library will implement a logic around it and helps the developer to manage his entities.

Through the implemented *CRUD* logic you will be able to focus on other things than the “classic” repetitive and boring data management.

The main concept is to use JSON dictionaries representing your entities. The logic to create, read or update your entities is done with just one single function. The delete logic has also been improved with a `deprecated` state.

Extending the NSManagedObject subclasses is required.

## Documentation

The complete documentation is available on [CocoaDocs](http://cocoadocs.org/docsets/DKDBManager).

The library is explained using Swift code. For an Obj-C example see the sample projects.

## Try it!

`pod try DKDBManager`







## Simple local database

This part explains how to create and configure a single local database that doesn’t need to be updated from an API.
In this case there is no need for deprecated entities or automatic updates.

As explained earlier, you first need the data inside a NSDictionary object.
This data will get parsed and the library will apply a CRUD logic on it.

In each extended class, implement the following methods:

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
		return NSPredicate(format: "name ==[c] %@", bookName)
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
### With MagicalRecord !

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

The recommended logic about child entities is to directly add their information in their parent's data.
Meaning, the NSDictionary object used to create a parent entity should also contains the information to create the child entities.

With such structure, the DKDBManager implements a _cascade process_ to create, update, save and delete child entities.

Some other functions must be implemented.

### Create and Update

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
        var bookSet = self.mutableSetValueForKey("pages")
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

### Save

When a parent entity got **saved as not deprecated** (manually or through the CRUD process) the [- updateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/updateWithDictionary:) function is not called and no CRUD logic reaches the child entities.

To complete the _cascase process_ to save the child entities, each model class should implement the [- saveEntityAsNotDeprecated](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/saveEntityAsNotDeprecated) method and forward it to its children.

	public override func saveEntityAsNotDeprecated() {
		// Method to save/store the current object AND all its child relations as not deprecated.
		super.saveEntityAsNotDeprecated()

		// Forward the process
		for page in (self.pages as? Set<Page> ?? []) {
			page.saveEntityAsNotDeprecated()
		}
	}

For more information about **deprecated entities** please read the **Database matching an API** section.

### Delete

The CRUD process or a specific user action might needs to **delete an entity**.
In most cases the child entities need to be removed as well.

This _cascade removal_ allows the developer to remove a complete structure of entities in just one single line:

	// Delete a book and all its pages and other child entities
	aBook.deleteWithReason("user does not want it anymore") 

To make sure the `pages` of this deleted `book` are also deleted implement the [- deleteChildEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteChildEntities) function.

	// remove all children of the current object
    public override func deleteChildEntities() {
        // super call
        super.deleteChildEntities()

		// Forward the delete process to every child.
        for page in (self.pages as? Set<Page> ?? []) {
			page.deleteEntityWithReason("parent book removed")
		}
	}

## Database matching an API

For many projects it is required to match a database hosted in a server and accessible through an API.
In most cases it delivers a big JSON data containing all informations about the entities.
Use the CRUD process to create and update your local models based on that data.

A good practice is to receive all this within a "cascade" structure.
Here is an example of data structure with `books` containing `pages` containing `images`:

	{
		"books" : [
			{
				"name":"LOTR",
				"order":1,
				"pages": [
					{
						"text": "abcde",
						"images": [
							...
						]
					}
				]
			},
			{
				"name":"The Hobbit",
				"order":2
				"pages" : [ ... ]
			}
		]
	}

But what about entities that do not exist anymore in the API? What about badly updated entities that become invalid? What about unchanged values and useless update processes?

The DKDBManager helps you deal with those cases just by implementing a few additional functions.

### Avoid useless update processes

Sometimes you might need to update just some entities and not all of them. But how can you do so when the CRUD process iterates through the whole JSON structure entity by entity?

The DKDBManager lets you choose whether an object needs an update or not. The function [- shouldUpdateEntityWithDictionary](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/shouldUpdateEntityWithDictionary:) receives as a parameter the JSON structure as a NSDictionary object.
You can use the current entity and the parameter to check if an update is needed or not.

For example; is the `updated_at` field the same in the JSON and in the local database?

- If so, return `false` and no update process will occur

- Otherwise return `true` and the [- updateWithDictionary:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/updateWithDictionary:) function will be called.

Due to the _cascade process_ if a parent entity _should **NOT** be updated_ then its child entities shouldn't either.

In order to **avoid useless actions** the update verification will _stop at the first valid and already updated parent_ object.
Its children will not get updated and the DKDBManager will not even ask them if they should be.

Here is an implementation of the function [- shouldUpdateEntityWithDictionary](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/shouldUpdateEntityWithDictionary:) that checks the lastest `update_at`:

	override public func shouldUpdateEntityWithDictionary(dictionary: [NSObject:AnyObject]!) -> Bool {
		// if the updated_at value from the dictionary is a different one.
		let lastUpdatedAt = (GET_DATE(dictionary, "updated_at") ?? NSDate())
		return (self.updated_at.isEqualToDate(lastUpdatedAt) == false)
	}

**TIP**

The parent `updated_at` timestamp should be refresh everytime one of its child gets updated. If so you will never miss a small update of the children or grand children of an entity.



### Deprecated entities

A **deprecated entity** is a NSManaged object not saved as `not deprecated` in the DKDBManager.

An object not saved as not deprecated is:

- An object where the CRUD process *didn't go through* (isn't sent by the API anymore?).

- An object marked as invalid (see **Invalid model entities** section).

- An object where a manual [- saveEntityAsNotDeprecated](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/saveEntityAsNotDeprecated) did not occur.

- An object where the CRUD process has a state that equals to `.Delete`

### Remove deprecated methods

To remove the deprecated entities call the function [+ removeDeprecatedEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/removeDeprecatedEntities) after the CRUD process (when refreshing the local database from an API) and before `saving` the current context to the persistent store.

	// CRUD process
	DKDBManager.createEntityFromDictionary(data)

	// Remove all deprecated entities (not set as 'not deprecated')
	DKDBManager.removeDeprecatedEntities()

	// Save the current context to the persistent store
	DKDBManager.saveToPersistentStoreWithCompletion() { /* Do something */}

### Save as not deprecated when nothing changed

If an entity did not change in the backend but is still sent through the API, your local database needs to save it as not deprecated.
But, as explained previously, if nothing changed the _cascase update process_ will stop on the first entity and not forward the process to its children.
By doing so they won't get updated nor saved as not deprecated.

When the [+ removeDeprecatedEntities](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Classes/DKDBManager.html#//api/name/removeDeprecatedEntities) occurs those unsaved entities will be removed.

To avoid such problems, implement the function [- saveEntityAsNotDeprecated](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/saveEntityAsNotDeprecated) inside your NSManagedObject subclasses. It will be called on the first valid parent model object and will be forwarded to every child.

For more information, see the **How to deal with child entities** section.

### Invalid model entities

The DKDBManager allows you to define whether an entity is invalid or not.

During the CRUD process an entity is tested to verify its validity. If [- invalidReason](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteIfInvalid) returns nil, no `invalidReason` has been found. Otherwise the reason will automatically be used and logged by the function [- deleteEntityWithReason:](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteEntityWithReason:).

The function [- invalidReason](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteIfInvalid) must be implemented inside a NSManagedObject subclass.

Here is an example of implementation:

	public override func invalidReason() -> String! {
		// Check the super class first.
		if let invalidReason = super.invalidReason() {
			return invalidReason
		}

		// Then verify the current required attributes.
		if (self.image == nil) {
			return "missing full screen image URL"	
		}
		if (self.pages.count == 0) {
			return "invalid relation with: Page - no entities found"
		}
		return nil
	}

If this function has been implemented, you can also manually delete invalid entities: [- deleteIfInvalid](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteIfInvalid)

	aBook.deleteIfInvalid()

Depending on the app and its architecture some entities could get invalid when something important has been removed or updated.
Or some could also become invalid after `removing the deprecated entities`.
If this is the case you have to check the deprecated entities manually.

To do so use the function [- deleteIfInvalid](http://cocoadocs.org/docsets/DKDBManager/0.5.2/Categories/NSManagedObject+DKDBManager.html#//api/name/deleteIfInvalid) on your model objects.

	class func checkAllDeprecatedEntities() {
        //
        // Check validity of ALL books and remove the invalid ones.
        if let books = self.all() as? [Book] {
            for book in books {
                book.deleteIfInvalid()
            }
        }
    }

## Tips

- Add more custom functions inside the helper files. All logic related to a class model should/could be inside this file. It helps a lot to structure the code. 

- Subclass the DKDBManager and use this new class to add more DB related functions. It keeps the `AppDelegate` cleaner.

- Generate the model classes in Obj-C. You will have no trouble with `optional` variables. Plus, the `NSSet` objects for `to-many`-relationships in the DB will have additional functions.

## Projects

`DKDBManager` is used in the following projects:

- [WhiteWall](https://itunes.apple.com/de/app/whitewall-fotolabor-bilder/id745169971)
- [Pons-SprachKalender](https://itunes.apple.com/de/app/sprachkalender-englisch-taglich/id901382448)
- [Pons-Bildwoerterbuch](https://itunes.apple.com/de/app/pons-bildworterbuch-englisch/id916712880)
- [ERGO ZahnPlan](https://itunes.apple.com/de/app/zahnplan/id882485101)
- [Digster Music Deals](https://itunes.apple.com/de/app/digster-music-deals/id916738237)
- Handhelp
- RezeptBOX
- Huethig
- *Your project here*

## Author

kevindelord, delord.kevin@gmail.com

## License

DKDBManager is available under the MIT license. See the LICENSE file for more info.

