//
//  PassengerViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import DKDBManager

class PassengerViewController	: UITableViewController {

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

	// MARK: - Segue

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Segue.OpenBaggages) {
			let vc = segue.destinationViewController as? BaggageViewController
			vc?.passenger = sender as? Passenger
		}
	}

	// MARK: - IBAction

	@IBAction func editButtonPressed() {

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

