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
    
    @available(*, deprecated, renamed: "dev_segmentId")
    var testing_segmentId: String { dev_segmentId }
    
    @available(*, deprecated, renamed: "dev_isTestUser")
    var testing_isTestUser: Bool { dev_isTestUser }
}
