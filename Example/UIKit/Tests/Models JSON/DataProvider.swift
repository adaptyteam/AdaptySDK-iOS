//
//  DataProvider.swift
//  Adapty_Tests
//
//  Created by Rustam on 09.12.2021.
//  Copyright © 2021 Adapty. All rights reserved.
//

import Foundation

class DataProvider: NSObject {
    func jsonDataNamed(_ name: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "json") else {
            fatalError("Missing file named: \(name).json")
        }
        return try Data(contentsOf: url)
    }
}
