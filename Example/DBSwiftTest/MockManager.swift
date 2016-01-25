//
//  MockManager.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation

class MockManager {

	// MARK: - Public Methods

	class func randomPlaneJSON() -> [[String:AnyObject]] {
		var data = [[String:AnyObject]]()

		for _ in 0...Int(arc4random_uniform(10) + 1) {
			data.append([JSON.Origin: self.randomCity(), JSON.Destination: self.randomCity(), JSON.Passengers: self.randomPassengerJSON()])
		}

		return data
	}

	class func randomPassengerJSON() -> [[String:AnyObject]] {
		var data = [[String:AnyObject]]()

		for _ in 0...Int(arc4random_uniform(10) + 1) {
			data.append([JSON.Name: self.randomName(), JSON.Age: Int(arc4random_uniform(20)) + 20, JSON.Baggages: self.randomBaggageJSON()])
		}

		return data
	}

	class func randomBaggageJSON() -> [[String:AnyObject]] {
		var data = [[String:AnyObject]]()

		for _ in 0...Int(arc4random_uniform(2) + 1) {
			data.append([JSON.Weight: Int(arc4random_uniform(20)) - 2])
		}

		return data
	}

	// MARK: - Private Methods

	private class func randomCity() -> String {
		let cities = self.cities()
		return cities[Int(arc4random_uniform(UInt32(cities.count)))]
	}

	private class func cities() -> [String] {
		return ["Paris", "London", "Berlin", "Tokyo", "Madrid", "Los Angles", "Toronto", "Sydney", "Hong Kong"]
	}

	private class func randomName() -> String {
		let names = self.names()
		return names[Int(arc4random_uniform(UInt32(names.count)))]
	}

	private class func names() -> [String] {
		return ["Kevin", "Michael", "James", "John", "Bob", "Pierre", "Alex", "Tom", "Jack", "Nicolas"]
	}
}