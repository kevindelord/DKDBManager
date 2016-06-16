//
//  PassengerViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import UIKit
import DKDBManager

class PassengerViewController	: TableViewController {

	var plane 					: Plane? = nil

	// MARK: - UITableView

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.plane?.allPassengersCount ?? 0)
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		if let
			passenger = self.plane?.allPassengersArray[indexPath.row],
			name = passenger.name,
			age = passenger.age,
			plane = passenger.plane {
				cell.textLabel?.text = "\(name) \(Int(age)) yo, \(passenger.allBaggagesCount) baggage(s)"
				cell.detailTextLabel?.text = "\(plane)"
		}
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.performSegueWithIdentifier(Segue.OpenBaggages, sender: self.plane?.allPassengersArray[indexPath.row])
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

		if (editingStyle == .Delete) {

				DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
					// Background Thread
					if let plane = self.plane?.entityInContext(savingContext) where (plane.allPassengersCount > indexPath.row) {
						let passenger = plane.allPassengersArray[indexPath.row]
						passenger.deleteEntityWithReason("Selective delete button pressed", inContext: savingContext)
					}

					}, completion: { (didSave: Bool, error: NSError?) -> Void in
						// Main Thread
						self.didDeleteItemAtIndexPath(indexPath)
				})
		}
	}

	// MARK: - Segue

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Segue.OpenBaggages) {
			let vc = segue.destinationViewController as? BaggageViewController
			vc?.passenger = sender as? Passenger
		}
	}

	// MARK: - IBAction

	@IBAction func editButtonPressed() {
		self.tableView.setEditing(!self.tableView.editing, animated: true)
	}

	@IBAction func removeAllEntitiesButtonPressed() {

		DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			if let plane = self.plane?.entityInContext(savingContext) {
				for passenger in plane.allPassengersArray {
					passenger.deleteEntityWithReason("Remove all passengers button pressed", inContext: savingContext)
				}
			}

			}) { (contextDidSave: Bool, error: NSError?) -> Void in
				// main thread
				self.tableView.reloadData()
		}
	}

	@IBAction func addEntitiesButtonPressed() {

		DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			if let
				plane = self.plane?.entityInContext(savingContext),
				passengers = Passenger.createEntitiesFromArray(MockManager.randomPassengerJSON(), inContext: savingContext) {
					plane.mutableSetValueForKey(JSON.Passengers).addObjectsFromArray(passengers)
			}

			}) { (contextDidSave: Bool, error: NSError?) -> Void in
				// main thread
				self.tableView.reloadData()
		}
	}
}

