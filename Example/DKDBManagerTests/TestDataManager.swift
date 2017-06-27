//
//  TestDataManager.swift
//  DKDBManager
//
//  Created by kevin delord on 20/06/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation
import DKDBManager

// MARK: - MockManager subclass of DKDBManager

class TestDataManager : DKDBManager {

	// MARK: -  Static Properties of MockManager

	override class func setupCoreDataStack(withName name: String) {
		MagicalRecord.setDefaultModelFrom(self)
		self.setupCoreDataStackWithInMemoryStore()
	}
}

// MARK: - Unit Test Methods

extension TestDataManager {

	class func staticPlaneJSON() -> [[String:AnyObject]] {
		let names = 	["Kevin", "Michael", "James", "Tim", "Bob", "Pierre", "Alex", "Tom", "Jack", "Nicolas", "Mauricio", "Ramiro", "Jon", "Arryn", "Li",
						"Lu", "Vegeta", "Goku", "", "Panos", "Lara", "Lila", "Anna", "Clara", "Tima"]

		let cities = 	["Paris", "London", "Berlin", "Madrid", "Toronto", ""]
		let ages = 		[21, 22, 34, 20, 45]
		let weightOfbaggages = [0, 20, 13, 14, 15, 8, 9, 22, 10]

		var data = [[String:AnyObject]]()
		for index in 0..<5 {
			// passenger
			var passenger = [[String:AnyObject]]()
			for passengerIndex in 0..<5 {
				// baggages
				var baggages = [[String:AnyObject]]()
				for baggageIndex in 0..<passengerIndex {
					baggages.append([JSON.Weight: weightOfbaggages[baggageIndex] as AnyObject])
				}

				let pIndex = (index * 5) + passengerIndex
				passenger.append([JSON.Name: names[pIndex] as AnyObject, JSON.Age: ages[passengerIndex] as AnyObject, JSON.Baggages: baggages as AnyObject])
			}

			// plane
			data.append([JSON.Origin: cities[index] as AnyObject, JSON.Destination: cities[index + 1] as AnyObject, JSON.Passengers: passenger as AnyObject])
		}
		return data
	}
}
