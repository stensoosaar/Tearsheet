//
//  File.swift
//  
//
//  Created by Sten Soosaar on 11.10.2023.
//

import Foundation

public extension Optional where Wrapped: Comparable {
    
    static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let leftValue = lhs, let righValue = rhs else {return false}
        return leftValue < righValue
    }
    
    static func > (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let leftValue = lhs, let righValue = rhs else {return false}
        return leftValue > righValue
    }
    
    static func <= (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let leftValue = lhs, let righValue = rhs else {return false}
        return leftValue <= righValue
    }
    
    static func >= (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let leftValue = lhs, let righValue = rhs else {return false}
        return leftValue >= righValue
    }
    
}
