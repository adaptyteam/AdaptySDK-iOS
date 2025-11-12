//
//  Adapty+Testing.swift
//  Adapty
//
//  Created by Alexey Goncharov on 2/11/25.
//

import Adapty
import Foundation

public extension AdaptyProfile {
    var testing_segmentId: String { segmentId }
    var testing_isTestUser: Bool { isTestUser }
    var testing_version: Int64 { version }
}
