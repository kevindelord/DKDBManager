//
//  BaggageViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import DKDBManager

class BaggageViewController		: UITableViewController {

	var passenger 				: Passenger? = nil

	// MARK: - UITableView

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.passenger?.allBaggagesCount ?? 0)
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		if let
			baggage = self.passenger?.allBaggagesArray[indexPath.row],
			weight = baggage.weight,
			passenger = baggage.passenger {
				cell.textLabel?.text = "Weight: \(weight)kg"
				cell.detailTextLabel?.text = "\(passenger)"
		}
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - IBAction

	@IBAction func editButtonPressed() {

	}

	@IBAction func removeAllEntitiesButtonPressed() {

		DKDBManager.saveWithBlock({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			if let passenger = self.passenger?.entityInContext(savingContext) {
				for baggage in passenger.allBaggagesArray {
					baggage.deleteEntityWithReason("Remove all baggages button pressed", inContext: savingContext)
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
				passenger = self.passenger?.entityInContext(savingContext),
				baggages = Baggage.createEntitiesFromArray(MockManager.randomBaggageJSON(), inContext: savingContext) {
					passenger.mutableSetValueForKey(JSON.Baggages).addObjectsFromArray(baggages)
			}

			}) { (contextDidSave: Bool, error: NSError?) -> Void in
				// main thread
				self.tableView.reloadData()
		}
	}
}

