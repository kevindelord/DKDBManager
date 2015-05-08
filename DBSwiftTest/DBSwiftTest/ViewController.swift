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

        self.createRunners()
        self.createSecondRunners()
        DKDBManager.deleteAllEntities()
        self.createRunners()
    }

    func createRunners() {

        let dict = ["name":"John", "position":13]
        Runner.createEntityFromDictionary(dict) { (runner, state: DKDBManagedObjectState) -> Void in
            if (runner != nil && state == .Create) {
                // did create runner
            }
        }

        let array = [dict, ["name":"Toto", "position":14]]
        Runner.createEntitiesFromArray(array)
        Runner.countEntity()
        DKDBManager.saveToPersistentStoreAndWait()
    }

    func createSecondRunners() {
        var array = [["name":"Alea", "position":16], ["name":"Proost", "position":17]]
        Runner.createEntitiesFromArray(array)
        Runner.countEntity()
        DKDBManager.saveToPersistentStoreAndWait()
    }

}

