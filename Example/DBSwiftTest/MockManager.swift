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
			data.append([JSON.Origin: self.randomCity() as AnyObject, JSON.Destination: self.randomCity() as AnyObject, JSON.Passengers: self.randomPassengerJSON() as AnyObject])
		}

		return data
	}

	class func randomPassengerJSON() -> [[String:AnyObject]] {
		var data = [[String:AnyObject]]()

		for _ in 0...Int(arc4random_uniform(10) + 1) {
			data.append([JSON.Name: self.randomName() as AnyObject, JSON.Age: Int(arc4random_uniform(20)) + 20 as AnyObject, JSON.Baggages: self.randomBaggageJSON() as AnyObject])
		}

		return data
	}

	class func randomBaggageJSON() -> [[String:AnyObject]] {
		var data = [[String:AnyObject]]()

		for _ in 0...Int(arc4random_uniform(2) + 1) {
			data.append([JSON.Weight: Int(arc4random_uniform(20)) - 2 as AnyObject])
		}

		return data
	}

	// MARK: - Private Methods

	fileprivate class func randomCity() -> String {
		let cities = self.cities()
		return cities[Int(arc4random_uniform(UInt32(cities.count)))]
	}

	fileprivate class func cities() -> [String] {
		return ["Paris", "London", "Berlin", "Tokyo", "Madrid", "Los Angles", "Toronto", "Sydney", "Hong Kong"]
	}

	fileprivate class func randomName() -> String {
		let names = self.names()
		return names[Int(arc4random_uniform(UInt32(names.count)))]
	}

	fileprivate class func names() -> [String] {
		return ["Kevin", "Michael", "James", "John", "Bob", "Pierre", "Alex", "Tom", "Jack", "Nicolas"]
	}
}
