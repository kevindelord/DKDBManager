//
//  ViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)


		print("---")
		Runner.countEntityInContext(NSManagedObjectContext.MR_defaultContext())
		print("---")

//        self.createRunners()
////        self.createSecondRunners()
////        DKDBManager.deleteAllEntities()
//
//		self.performBlockAfterDelay(2, block: { () -> Void in
//			        self.createRunners()
//			}, completion: nil)
//
		self.createRunners()

//		self.performBlockAfterDelay(5, block: { () -> Void in
//			print("---")
//			DKDBManager.dumpInContext(NSManagedObjectContext.MR_defaultContext())
////			Runner.countEntityInContext(NSManagedObjectContext.MR_defaultContext())
//
////			DKDBManager.saveWithBlock({ (context: NSManagedObjectContext) -> Void in
////				DKDBManager.deleteAllEntitiesInContext(context)
////			})
//			print("---")
//
//		})

    }

	func lol() {

		let dict = ["name":"Bob", "position":14]

		DKDBManager.saveWithBlock({ (context: NSManagedObjectContext) -> Void in

			Runner.createEntityFromDictionary(dict, context: context) { (runner, state: DKDBManagedObjectState) -> Void in
				print("status: \(state.rawValue) - entity: \(runner)")
			}
		})
		print(dict)
	}

    func createRunners() {

        let dict = ["name":"John", "position":13]


		DKDBManager.saveWithBlockAndWait({ (context: NSManagedObjectContext) -> Void in

			print("1.isMainThread: ")
			print(NSThread.currentThread().isMainThread)
			Runner.createEntityFromDictionary(dict, context: context) { (runner, state: DKDBManagedObjectState) -> Void in
				print("status: \(state.rawValue) - entity: \(runner)")
				print("2.isMainThread: ")
				print(NSThread.currentThread().isMainThread)
			}
			})//, completion: nil)

//        Runner.createEntityFromDictionary(dict) { (runner, state: DKDBManagedObjectState) -> Void in
//            if (runner != nil && state == .Create) {
//                // did create runner
//            }
//        }

//        let array = [dict, ["name":"Toto", "position":14]]
//        Runner.createEntitiesFromArray(array)
//        Runner.countEntity()
//        DKDBManager.saveToPersistentStoreAndWait()
    }

    func createSecondRunners() {
//        let array = [["name":"Alea", "position":16], ["name":"Proost", "position":17]]
//        Runner.createEntitiesFromArray(array)
//        Runner.countEntity()
//        DKDBManager.saveToPersistentStoreAndWait()
    }

}

