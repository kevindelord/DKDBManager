# DKDBManager

[![Version](https://img.shields.io/cocoapods/v/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![License](https://img.shields.io/cocoapods/l/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Platform](https://img.shields.io/cocoapods/p/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)

## Concept


## Installation

DKDBManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DKDBManager"

and run `pod install` from the main directory.

## Getting Started

To get started, first, import the header file DKDBManager.h in your project's pch file. This will import in your project all required headers for `DKHelpers`, `Magical Record` and CoredData.

As the `DKDBManager` is a light wrapper around [Magical Record](https://github.com/magicalpanda/MagicalRecord) you first need to implement some minor and basic methods. The best way to use it would be to subclass the manager itself. Afterwhat you still have to update your AppDelegate and create categories (or extensions in Swift) implementing the `DKDBManagedObject` protolcol for your models.

### XYDBManager subclass of DKDBManager

In this subclass you need two methods. 
The first one is needed to setup the CoreData stack with a specifc name. Of course you can play with the name to change your database on startup whenever you would like to.
A good practice will be to call this method at the beginning of the `application:application didFinishLaunchingWithOptions:launchOptions` method of your `AppDelegate`.

	@implementation XYDBManager
		+ (void)setup {

		    BOOL didResetDB = [self setupDatabaseWithName:@"XYAwesomeDatabaseName.sqlite"];
		    if (didResetDB) {
				// The database is fresh new.
				// Depending on your needs you might want to do something special right now as:.
				// - Setting up some user defaults.
				// - Deal with your api/store manager.
				// etc.
			}
			// Starting this point your database is ready to use.
			// You can now create any object you could need.
		}

The second method is required to tell the manager which models should be proceed when deleting deprecated or loging entities.

		+ (NSArray *)entities {
			// Simply return an array of class names as strings.
		    return @[NSStringFromClass(Plane.class),
		             NSStringFromClass(Pilot.class),
		             NSStringFromClass(Passenger.class)];
		}
	@end

### Configuration

Of course you can also configure how the manager will react on execution. Add the following lines before calling `setupDatabaseWithName` inside the `setup` method:

Enable the log or not. *default NO*

	XYDBManager.verbose = YES;

Allow the manager to update the entities when parsing new data. *default YES*

    XYDBManager.allowUpdate = YES;

Completely reset the database on startup. *default NO*
Instead of removing your app from the simulator just activate this flag and the local DB will be brand new when your app starts.

    XYDBManager.resetStoredEntities = NO;

When parsing new entities force the manager to update the entities no matter what. *default NO*

    XYDBManager.needForcedUpdate = NO;


### AppDelegate

In this file you have to `setup` the CoreData stack on start up and `cleanUp` before your app exits.

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	    [XYDBManager setup];
	    // whatever else here...

	    return YES;
	}

	- (void)applicationWillTerminate:(UIApplication *)application {
		[XYDKManager cleanUp];
	}

## TODO

- Improve log
- Improve documentaion
- Add method to delete all entities for a specific model.
- Add tests

## Author

kevindelord, delord.kevin@gmail.com

## License

DKDBManager is available under the MIT license. See the LICENSE file for more info.

