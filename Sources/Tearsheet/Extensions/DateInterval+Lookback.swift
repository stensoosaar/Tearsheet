//
//  File.swift
//  
//
//  Created by Sten on 28.10.2022.
//

import Foundation

public extension DateInterval {
	
	static func lookback(_ value: Int, unit: Calendar.Component, until endDate: Date = Date()) -> DateInterval {
		guard let startDate = Calendar.current.date(byAdding: unit, value: -1 * abs(value), to: endDate) else {
			fatalError("cant calculate subscription start date")
		}
		return DateInterval(start: startDate.startOfDay, end: endDate.endOfDay)
	}
	
	static func period(_ value: Int, unit: Calendar.Component, from startDate: Date = Date()) -> DateInterval {
		guard let endDate = Calendar.current.date(byAdding: unit, value: 1 * abs(value), to: startDate) else {
			fatalError("cant calculate subscription end date")
		}
		return DateInterval(start: startDate.startOfDay, end: endDate.endOfDay)
	}
	
	func contains(date: Date?) -> Bool {
		
		guard let date = date else { return false}
		return self.contains(date)
		
	}
	
	
}
