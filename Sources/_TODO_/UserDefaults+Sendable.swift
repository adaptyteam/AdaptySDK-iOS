//
//  UserDefaults+Sendable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.09.2024
//

import Foundation

#if compiler(>=6.0)
    extension UserDefaults: @retroactive @unchecked Sendable {}
#else
    extension UserDefaults: @unchecked Sendable {}
#endif
