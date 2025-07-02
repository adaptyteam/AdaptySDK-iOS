//
//  CodingUserInfoContainer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2024
//

import Foundation

#if compiler(>=6.1.0)
    package typealias CodingUserInfo = [CodingUserInfoKey: any Sendable]
#else
    package typealias CodingUserInfo = [CodingUserInfoKey: Any]
#endif

package protocol CodingUserInfoContainer: AnyObject {
    var userInfo: CodingUserInfo { get set }
}

extension JSONDecoder: CodingUserInfoContainer {}
extension JSONEncoder: CodingUserInfoContainer {}
