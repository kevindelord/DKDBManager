# DKDBManager

[![Version](https://img.shields.io/cocoapods/v/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![License](https://img.shields.io/cocoapods/l/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Platform](https://img.shields.io/cocoapods/p/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)

## Concept

DKDBManager is simple, yet very useful, CRUD manager around [Magical Record](https://github.com/magicalpanda/MagicalRecord). *MR* is already very easy-to-use, less-to-code, wonderful CoreData wrapper. The current library will implement a logic around this to help you to manage your entities. Through the implemented *CRUD* logic you will be able to focus on other things than the classic-repetitivly boring data management.

## Documentation

The complete documentation is available on [CocoaDocs](http://cocoadocs.org/docsets/DKDBManager).

## Installation

DKDBManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DKDBManager"

and run `pod install` from the main directory.

## Getting Started

To get started, first, import the header file DKDBManager.h in your project's pch file. This will import in your project all required headers for `DKHelpers`, `Magical Record` and CoredData.

    #import "DKDBManager.h"

As the `DKDBManager` is a light wrapper around [Magical Record](https://github.com/magicalpanda/MagicalRecord) you first need to implement minor methods within your AppDelegate. Afterwhat you still have to generate your model classes and create categories (or extensions in Swift).

### AppDelegate using DKDBManager

First you need to setup the CoreData stack with a specifc file name. Of course you can play with the name to change your database on startup whenever you would like to.
A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions` method of your `AppDelegate`.
You could also sublclass the DKDBManager and wrap the following in a dedicated class. 

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

		BOOL didResetDB = [DKDBManager setupDatabaseWithName:@"DKDatabaseName.sqlite"];
	    if (didResetDB) {
			// The database is fresh new.
			// Depending on your needs you might want to do something special right now as:.
			// - Setting up some user defaults.
			// - Deal with your api/store manager.
			// etc.
		}
		// Starting this point your database is ready to use.
		// You can now create any object you could need.

	    return YES;
	}

	- (void)applicationWillTerminate:(UIApplication *)application {
		[DKDBManager cleanUp];
	}

### Configuration

You can configure how the manager will react on execution. Add the following lines before calling `setupDatabaseWithName:`:

Enable the log or not. *default NO*

	DKDBManager.verbose = YES;

Allow the manager to update the entities when parsing new data. *default YES*

    DKDBManager.allowUpdate = YES;

Completely reset the database on startup. *default NO*
Instead of removing your app from the simulator just activate this flag and the local DB will be brand new when your app starts.

    DKDBManager.resetStoredEntities = NO;

When parsing new entities force the manager to update the entities no matter what. *default NO*

    DKDBManager.needForcedUpdate = NO;

### Models Configuration

The models configuration is done as in any other projects.

First create and configure your model entities inside the `.xcdatamodel` file.
Then generate with Xcode the NSManagedObject subclasses as you are used to.

After that, create category files (or extensions in Swift) for each model.
The functions and logic will be implemented in those files. If it was done in the generated files, your changes would be removed everytime you generate them again.

__warning__ If your code is in Swift you can either generate the NSManagedObject subclasses in _Swift_ or _Obj-C_.

- _Swift_: add `@objc(ClassName)` before the implementation:

		@objc(Entity)
		class Entity: NSManagedObject {
			@NSManaged var createdAt: NSDate?
			@NSManaged var updatedAt: NSDate?
		}

- _Obj-C_: import the class header in the bridge-header file.

		#import "Entity.h"

### Simple local database

### Database matching API

### MagicalRecord request

## Projects

`DKDBManager` is used in the following projects:

- WhiteWall
- Pons-SprachKalender
- Pons-Bildwörterbuch
- ERGO ZahnPlan
- Handhelp
- RezeptBOX
- Hüthig
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

