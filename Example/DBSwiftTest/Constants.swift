//
//  Constants.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation

struct Segue {
	static let OpenPassengers	= "OpenPassengerForPlane"
	static let OpenBaggages		= "OpenBaggageForPassenger"
}

struct JSON {
	static let Destination		= "destination"
	static let Origin 			= "origin"
	static let Passengers 		= "passengers"
	static let Baggages 		= "baggages"
	static let Plane 			= "plane"
	static let Name 			= "name"
	static let Age 				= "age"
	static let Weight			= "weight"
}

struct Verbose {

	static let DatabaseManager	= true

	struct Model {
		static let Plane		= true
		static let Passenger	= true
		static let Baggage		= true
	}
}