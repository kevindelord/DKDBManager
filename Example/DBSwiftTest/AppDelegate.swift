//
//  AppDelegate.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import UIKit
import DKDBManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		// Optional: Enable the log
		DKDBManager.setVerbose(Verbose.DatabaseManager)
		// Optional: Reset the database on start to make this test app more understandable.
		DKDBManager.setResetStoredEntities(false)
		// Setup the database.
		DKDBManager.setup()

		// Starting this point your database is ready to use.
        // You can now create any object you could need.

        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DKDBManager.cleanUp()
    }
}

