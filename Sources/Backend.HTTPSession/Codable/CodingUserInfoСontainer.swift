//
//  CodingUserInfoСontainer.swift
//
//
//  Created by Aleksei Valiano on 08.04.2024
//
//

import Foundation

package protocol CodingUserInfoСontainer: AnyObject {
#if compiler(>=6.1.0)
    var userInfo: [CodingUserInfoKey: any Sendable] { get set }
#else
    var userInfo: [CodingUserInfoKey: Any] { get set }
#endif
}

extension JSONDecoder: CodingUserInfoСontainer {}
extension JSONEncoder: CodingUserInfoСontainer {}
