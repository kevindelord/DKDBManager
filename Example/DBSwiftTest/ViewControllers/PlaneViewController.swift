//
//  ViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 Smart Mobile Factory. All rights reserved.
//

import UIKit
import DKDBManager

class PlaneViewController	: TableViewController {

	// MARK: - UITableView

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Plane.count()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		if let plane = (Plane.all() as? [Plane])?[indexPath.row] {
			cell.textLabel?.text = "\(plane.origin ?? "n/a") -> \(plane.destination ?? "n/a")"
			cell.detailTextLabel?.text = "\(plane.allPassengersCount) passenger(s)"
		}
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.performSegueWithIdentifier(Segue.OpenPassengers, sender: (Plane.all() as? [Plane])?[indexPath.row])
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

		if (editingStyle == .Delete),
			let plane = (Plane.all() as? [Plane])?[indexPath.row] {

				DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
					// Background Thread
					plane.deleteEntityWithReason("Selective delete button pressed", inContext: savingContext)

					}, completion: { (didSave: Bool, error: NSError?) -> Void in
						// Main Thread
						self.didDeleteItemAtIndexPath(indexPath)
				})
		}
	}

	// MARK: - Segue

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Segue.OpenPassengers) {
			let vc = segue.destinationViewController as? PassengerViewController
			vc?.plane = sender as? Plane
		}
	}

	// MARK: - IBAction

	@IBAction func editButtonPressed() {
		self.tableView.setEditing(!self.tableView.editing, animated: true)
	}

	@IBAction func removeAllEntitiesButtonPressed() {

		DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			for plane in (Plane.all() as? [Plane] ?? []) {
				if let plane = plane.entityInContext(savingContext) {
					plane.deleteEntityWithReason("Remove all planes button pressed", inContext: savingContext)
				}
			}

			}) { (contextDidSave: Bool, error: NSError?) -> Void in
				// main thread
				self.tableView.reloadData()
		}
	}

	@IBAction func addEntitiesButtonPressed() {

		let json = MockManager.randomPlaneJSON()

		DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			Plane.createEntitiesFromArray(json, inContext: savingContext)

			}) { (contextDidSave: Bool, error: NSError?) -> Void in
				// main thread
				self.tableView.reloadData()
		}
	}
}

