//
//  ViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import UIKit

class PlaneViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Planes"
		self.view.backgroundColor = UIColor.whiteColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Plane.count()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		if let plane = (Plane.all() as? [Plane])?[indexPath.row] {
			cell.textLabel?.text = "\(plane.origin ?? "n/a") -> \(plane.destination ?? "n/a")"
			cell.detailTextLabel?.text = "ferf"//"\(plane.passengers))"
		}
		return cell
	}

	@IBAction func addEntitiesButtonPressed() {

		let json = self.planeJSON()

		DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread

			Plane.createEntitiesFromArray(json, inContext: savingContext)

			}) { (contextDidSave: Bool, error: NSError?) -> Void in
				// main thread
				self.tableView.reloadData()
		}
	}

	private func planeJSON() -> [[String:AnyObject]] {
		return [
			[JSON.Origin: "Paris", JSON.Destination: "Berlin"],
			[JSON.Origin: "Paris", JSON.Destination: "Tokyo"],
			[JSON.Origin: "London", JSON.Destination: "Berlin"],
			[JSON.Origin: "Tokyo", JSON.Destination: "Berlin"]
		]
	}
}

