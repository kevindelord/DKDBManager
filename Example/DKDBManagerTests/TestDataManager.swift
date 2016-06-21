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

	override class func setupCoreDataStackWithName(name: String) {
		MagicalRecord.setDefaultModelFromClass(self)
		self.setupCoreDataStackWithInMemoryStore()
	}
}

// MARK: - Unit Test Methods

extension TestDataManager {

	class func staticPlaneJSON(entityNumber: Int = 5) -> [[String:AnyObject]] {
		let names = 	["Kevin", "Michael", "James", "Tim", "Bob", "Pierre", "Alex", "Tom", "Jack", "Nicolas"]
		let cities = 	["Paris", "London", "Berlin", "", "Madrid", "Los Angles", "Toronto", "Sydney", "Hong Kong"]
		let ages = 		[21, 22, 34, 20, 45, 44, 32, 19, 79]
		let numberOfbaggages = [0, 1, 2, 2, 1, 0, 1, 3, 1]
		let weightOfbaggages = [0, 20, 13, 14, 15, 8, 9, 22, 10]

		var data = [[String:AnyObject]]()

		for index in 0..<entityNumber {
			// baggages
			var baggages = [[String:AnyObject]]()
			for baggageIndex in 0..<numberOfbaggages[index] {
				baggages.append([JSON.Weight: weightOfbaggages[baggageIndex]])
			}

			// passenger
			var passenger = [[String:AnyObject]]()
			for index in 0..<entityNumber {
				passenger.append([JSON.Name: names[index], JSON.Age: ages[index], JSON.Baggages: baggages])
			}

			// plane
			data.append([JSON.Origin: cities[index], JSON.Destination: cities[index + 1], JSON.Passengers: passenger])
		}

		return data
	}
}