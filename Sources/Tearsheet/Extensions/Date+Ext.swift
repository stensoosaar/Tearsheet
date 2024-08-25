//
//  File.swift
//  
//
//  Created by Sten on 27.09.2023.
//

import Foundation


public extension Date {
	
	var startOfDay: Date {
		return Calendar.current.startOfDay(for: self)
	}

	var endOfDay: Date {
		var components = DateComponents()
		components.day = 1
		components.second = -1
		return Calendar.current.date(byAdding: components, to: startOfDay)!
	}
	
	var thirdFridayOfMonth: Date {
		return Calendar.current.nextDate(after: self, matching: DateComponents(weekday: 6, weekOfMonth: 3), matchingPolicy: .nextTime)!
	}

	var startOfMonth: Date {
		let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
		return Calendar.current.date(from: components)!
	}

	var endOfMonth: Date {
		var components = DateComponents()
		components.month = 1
		components.second = -1
		return Calendar.current.date(byAdding: components, to: startOfMonth)!
	}
	
	var dateValue: Date? {
		let cal = Calendar.current
		let comps = cal.dateComponents([.year,.month,.day], from: self)
		return cal.date(from: comps)
	}
	
	init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
		let comps = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
		guard let date = Calendar.current.date(from: comps) else {
			fatalError("\(year)-\(month)-\(day) invalid values to make date")
		}
		self.init(timeIntervalSince1970: date.timeIntervalSince1970)
	}
	
	func floor(to timeInterval: TimeInterval)->Date{
		let remainder = -1 * timeIntervalSince1970.truncatingRemainder(dividingBy: timeInterval)
		return addingTimeInterval(remainder)
	}
	
	static func timeInterval(microsecondsSince1970 microseconds:Int) -> Date {
		Date(timeIntervalSince1970: Double(microseconds / 1_000_000))
	}
	
}
