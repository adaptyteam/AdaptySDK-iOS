//
//  Array+SingleItem.swift
//  Adapty
//
//  Created by Alex Goncharov on 11/02/2026.
//

import Foundation

extension Array {
    var firstIfSingle: Element? { count == 1 ? first : nil }
}
