//
//  IdentifiableErrorWrapper.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Alexey Goncharov on 2/17/25.
//

import Foundation

struct IdentifiableErrorWrapper: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let error: Error
}
