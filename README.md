# DKDBManager

[![Version](https://img.shields.io/cocoapods/v/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![License](https://img.shields.io/cocoapods/l/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)
[![Platform](https://img.shields.io/cocoapods/p/DKDBManager.svg?style=flat)](http://cocoadocs.org/docsets/DKDBManager)

## Concept

DKDBManager is simple, yet very useful, helper/manager around [Magical Record](https://github.com/magicalpanda/MagicalRecord). *MR* already is a very helpful, easy-to-use, less-to-code, wonderful CoreData wrapper. The current library will implement a logic around this to help you to manage your entities. Through the implemented *CRUD* logic you will be able to focus on other things than the classic-repetitivly boring data management.

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

Of course you can also configure how the manager will react on execution. Add the following lines before calling `setupDatabaseWithName:` inside the `setup` method:

Enable the log or not. *default NO*

	XYDBManager.verbose = YES;

Allow the manager to update the entities when parsing new data. *default YES*

    XYDBManager.allowUpdate = YES;

Completely reset the database on startup. *default NO*
Instead of removing your app from the simulator just activate this flag and the local DB will be brand new when your app starts.

    XYDBManager.resetStoredEntities = NO;

When parsing new entities force the manager to update the entities no matter what. *default NO*

    XYDBManager.needForcedUpdate = NO;

### Model : Plane

To be explained soon...

- NSManagedObject subclass
- Categories/extensions
- Completion block
- MagicalRecord request

## Logging

As you will when running your app Magical Record does log a lot of things. It's quite handy but could be a bit annoying. 
Until the release version 2.3.0 the only [working solution](http://stackoverflow.com/questions/15284067/cocoapods-turning-magicalrecord-logging-off) to disable the log is to add the following to your Podfile as a 'post_install' hook:

	post_install do |installer|
	  target = installer.project.targets.find{|t| t.to_s == "Pods-MagicalRecord"}
	    target.build_configurations.each do |config|
	        s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
	        s = [ '$(inherited)' ] if s == nil;
	        s.push('MR_ENABLE_ACTIVE_RECORD_LOGGING=0') if config.to_s == "Debug";
	        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
	    end
	end

PS: disable the log once your database is working fine ;)

## Projects

`DKDBManager` is used in the following projects:

- WhiteWall
- Pons-SprachKalender
- ZahnPlan
- *Your project here*

## TODO

- Improve documentaion
- Add tests
- Add project links

## Author

kevindelord, delord.kevin@gmail.com

## License

DKDBManager is available under the MIT license. See the LICENSE file for more info.

