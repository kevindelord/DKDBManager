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

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.plane?.allPassengersCount ?? 0)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		if let
			passenger = self.plane?.allPassengersArray[indexPath.row],
			let name = passenger.name,
			let age = passenger.age,
			let plane = passenger.plane {
				cell.textLabel?.text = "\(name) \(Int(age)) yo, \(passenger.allBaggagesCount) baggage(s)"
				cell.detailTextLabel?.text = "\(plane)"
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.performSegue(withIdentifier: Segue.OpenBaggages, sender: self.plane?.allPassengersArray[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

		if (editingStyle == .delete) {

			DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
				// Background Thread
				if let plane = self.plane?.entity(in: savingContext), (plane.allPassengersCount > indexPath.row) {
					let passenger = plane.allPassengersArray[indexPath.row]
					passenger.deleteEntity(withReason: "Selective delete button pressed", in: savingContext)
				}

			}, completion: { (didSave: Bool, error: Error?) -> Void in
				// Main Thread
				self.didDeleteItemAtIndexPath(indexPath)
			})
		}
	}

	// MARK: - Segue

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == Segue.OpenBaggages) {
			let vc = segue.destination as? BaggageViewController
			vc?.passenger = sender as? Passenger
		}
	}

	// MARK: - IBAction

	@IBAction func editButtonPressed() {
		self.tableView.setEditing(!self.tableView.isEditing, animated: true)
	}

	@IBAction func removeAllEntitiesButtonPressed() {

		DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			if let plane = self.plane?.entity(in: savingContext) {
				for passenger in plane.allPassengersArray {
					passenger.deleteEntity(withReason: "Remove all passengers button pressed", in: savingContext)
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
				plane = self.plane?.entity(in: savingContext),
				let passengers = Passenger.crudEntities(with: MockManager.randomPassengerJSON(), in: savingContext) {
				plane.mutableSetValue(forKey: JSON.Passengers).addObjects(from: passengers)
			}

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			self.tableView.reloadData()
		})
	}
}

