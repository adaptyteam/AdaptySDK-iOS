//
//  CodingUserInfoСontainer.swift
//
//
//  Created by Aleksei Valiano on 08.04.2024
//
//

import Foundation

protocol CodingUserInfoСontainer: AnyObject {
    var userInfo: [CodingUserInfoKey: Any] { get set }
}

extension JSONDecoder: CodingUserInfoСontainer {}
extension JSONEncoder: CodingUserInfoСontainer {}
