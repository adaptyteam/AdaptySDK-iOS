//
//  UserDefaultsMock.swift
//  Adapty_Tests
//
//  Created by Andrey Kyashkin on 27.11.2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

import Foundation

class UserDefaultsMock: UserDefaults {
    var removedObjectsKeys: [String] = []
    var calledObjectKey: String?

    var mockValues: [String: Any] = [:]

    override func set(_ value: Any?, forKey defaultName: String) {
        mockValues[defaultName] = value
    }

    override func removeObject(forKey defaultName: String) {
        removedObjectsKeys.append(defaultName)
        mockValues.removeValue(forKey: defaultName)
    }

    override func string(forKey defaultName: String) -> String? {
        return mockValues[defaultName] as? String
    }

    override func object(forKey defaultName: String) -> Any? {
        calledObjectKey = defaultName
        return mockValues[defaultName]
    }

    override func array(forKey defaultName: String) -> [Any]? {
        return mockValues[defaultName] as? [Any]
    }

    override func dictionary(forKey defaultName: String) -> [String: Any]? {
        return mockValues[defaultName] as? [String: Any]
    }
}
