//
//  JSONCodable.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 06/11/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

protocol JSONCodable {
    init?(json: Parameters) throws
}
