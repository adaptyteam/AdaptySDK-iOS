//
//  JSONCodable.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 06/11/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

extension SerializationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missing(let params): return "Missing some of the required params: \(params)"
        case .invalid(let property, let data): return "Received invalid \(property): \(data)"
        }
    }
}

protocol JSONCodable {
    init?(json: Parameters) throws
}
