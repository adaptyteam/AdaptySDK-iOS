//
//  AdaptyProfile.swift
//  AdaptyDeveloperTools
//
//  Created by Alexey Goncharov on 2/11/25.
//

import Adapty

public extension AdaptyProfile {
    var dev_segmentId: String { segmentId }
    var dev_isTestUser: Bool { isTestUser }
    var dev_version: Int64 { version }
}
