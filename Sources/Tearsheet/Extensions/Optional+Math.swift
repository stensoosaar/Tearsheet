//
//  File.swift
//  
//
//  Created by Sten on 08.11.2022.
//

import Foundation


public extension Optional where Wrapped: AdditiveArithmetic {
	
	static func + (lhs: Wrapped?, rhs: Wrapped?) -> Optional {
		switch (lhs, rhs) {
		case let (.some(lhs), .some(rhs)):	return lhs + rhs
		case let (.some(value), .none):		return value
		case let (.none, .some(value)):		return value
		default:							return nil
		}
	}

	static func - (lhs: Wrapped?, rhs: Wrapped?) -> Optional {
		switch (lhs, rhs) {
		case let (.some(lhs), .some(rhs)):	return lhs - rhs
		case let (.some(value), .none):		return value
		case let (.none, .some(value)):		return value
		default:							return nil
		}
	}

}


public extension Optional where Wrapped: Numeric {
	
	static func * (lhs: Wrapped?, rhs: Wrapped?) -> Optional {
		switch (lhs, rhs) {
		case let (.some(lhs), .some(rhs)):	return lhs * rhs
		case let (.some(value), .none):		return value
		case let (.none, .some(value)):		return value
		default:							return nil
		}
	}
	
}


public extension Optional where Wrapped: BinaryInteger {
	
	static func / (lhs: Wrapped?, rhs: Wrapped?) -> Optional {
		switch (lhs, rhs) {
		case let (.some(lhs), .some(rhs)):	return lhs / rhs
		case let (.some(value), .none):		return value
		case let (.none, .some(value)):		return value
		default:							return nil
		}
	}

}


public extension Optional where Wrapped: FloatingPoint {
	
	static func / (lhs: Wrapped?, rhs: Wrapped?) -> Optional {
		switch (lhs, rhs) {
		case let (.some(lhs), .some(rhs)):	return lhs / rhs
		case let (.some(value), .none):		return value
		case let (.none, .some(value)):		return value
		default:							return nil
		}
	}

}
