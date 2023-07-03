//
//  Dictionary.swift
//  dayMind
//
//  Created by 강영민 on 2023/07/01.
//

import Foundation

extension Dictionary {
    func mapKeys<T>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var dictionary: [T: Value] = [:]
        for (key, value) in self {
            dictionary[try transform(key)] = value
        }
        return dictionary
    }
}
