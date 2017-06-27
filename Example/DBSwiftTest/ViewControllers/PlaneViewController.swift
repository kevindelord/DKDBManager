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

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Plane.count()
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		if let plane = (Plane.all() as? [Plane])?[indexPath.row] {
			cell.textLabel?.text = "\(plane.origin ?? "n/a") -> \(plane.destination ?? "n/a")"
			cell.detailTextLabel?.text = "\(plane.allPassengersCount) passenger(s)"
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.performSegue(withIdentifier: Segue.OpenPassengers, sender: (Plane.all() as? [Plane])?[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

		if (editingStyle == .delete),
			let plane = (Plane.all() as? [Plane])?[indexPath.row] {

			DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
				// Background Thread
				plane.deleteEntity(withReason: "Selective delete button pressed", in: savingContext)

			}, completion: { (didSave: Bool, error: Error?) -> Void in
				// Main Thread
				self.didDeleteItemAtIndexPath(indexPath)
			})
		}
	}

	// MARK: - Segue

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == Segue.OpenPassengers) {
			let vc = segue.destination as? PassengerViewController
			vc?.plane = sender as? Plane
		}
	}

	// MARK: - IBAction

	@IBAction func editButtonPressed() {
		self.tableView.setEditing(!self.tableView.isEditing, animated: true)
	}

	@IBAction func removeAllEntitiesButtonPressed() {

		DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			for plane in (Plane.all() as? [Plane] ?? []) {
				if let plane = plane.entity(in: savingContext) {
					plane.deleteEntity(withReason: "Remove all planes button pressed", in: savingContext)
				}
			}

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			self.tableView.reloadData()
		})
	}

	@IBAction func addEntitiesButtonPressed() {

		let json = MockManager.randomPlaneJSON()

		DKDBManager.save({ (savingContext: NSManagedObjectContext) -> Void in
			// background thread
			Plane.crudEntities(with: json, in: savingContext)

		}, completion: { (contextDidSave: Bool, error: Error?) -> Void in
			// main thread
			self.tableView.reloadData()
		})
	}
}

