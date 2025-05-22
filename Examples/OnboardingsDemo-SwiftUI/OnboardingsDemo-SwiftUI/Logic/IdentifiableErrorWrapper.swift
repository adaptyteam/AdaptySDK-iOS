//
//  IdentifiableErrorWrapper.swift
//  OnboardingsDemo-SwiftUI
//
//  Created by Aleksey Goncharov on 12.08.2024.
//

import Foundation

struct IdentifiableErrorWrapper: Identifiable {
    var id: String = UUID().uuidString
    var value: Error
}
