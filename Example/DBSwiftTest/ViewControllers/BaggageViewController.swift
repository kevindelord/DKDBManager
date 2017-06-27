//
//  BaggageViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import UIKit
import DKDBManager

class BaggageViewController		: TableViewController {

	var passenger 				: Passenger? = nil

	// MARK: - UITableView

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.passenger?.allBaggagesCount ?? 0)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		if let
			baggage = self.passenger?.allBaggagesArray[indexPath.row],
			let weight = baggage.weight,
			let passenger = baggage.passenger {
				cell.textLabel?.text = "Weight: \(weight)kg"
				cell.detailTextLabel?.text = "\(passenger)"
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

		if (editingStyle == .delete) {

			DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
				// Background Thread
				if let passenger = self.passenger?.entity(in: savingContext), (passenger.allBaggagesCount > indexPath.row) {
					let baggage = passenger.allBaggagesArray[indexPath.row]
					baggage.deleteEntity(withReason: "Selective delete button pressed", in: savingContext)
				}

			}, completion: { (didSave: Bool, error: Error?) -> Void in
				// Main Thread
				self.didDeleteItemAtIndexPath(indexPath)
			})
		}
	}

	// MARK: - IBAction

	@IBAction func editButtonPressed() {
		self.tableView.setEditing(!self.tableView.isEditing, animated: true)
	}

	@IBAction func removeAllEntitiesButtonPressed() {

		DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			if let passenger = self.passenger?.entity(in: savingContext) {
				for baggage in passenger.allBaggagesArray {
					baggage.deleteEntity(withReason: "Remove all baggages button pressed", in: savingContext)
				}
			}

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			self.tableView.reloadData()
		})
	}

	@IBAction func addEntitiesButtonPressed() {

		DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			if let
				passenger = self.passenger?.entity(in: savingContext),
				let baggages = Baggage.crudEntities(with: MockManager.randomBaggageJSON(), in: savingContext) {
				passenger.mutableSetValue(forKey: JSON.Baggages).addObjects(from: baggages)
			}

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			self.tableView.reloadData()
		})
	}
}

