//
//  User.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation

struct User: Equatable {
    let id: String
    let name: String
    var isPremium: Bool
    
    mutating func updateIsPremium(_ newValue: Bool) {
        isPremium = newValue
    }
}
