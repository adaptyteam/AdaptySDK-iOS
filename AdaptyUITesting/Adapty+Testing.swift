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
}

public extension AdaptyOnboarding {
    var testing_requestLocaleId: String { self.requestLocaleIdentifier }
}
