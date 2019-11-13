//
//  ResponseStatusModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

struct ResponseStatusModel {
    
    enum ResponseStatus: String {
        case success
        case failure
    }
    
    let status: ResponseStatus
    let errorCode: String?
    let message: String?
    
}

extension ResponseStatusModel: JSONCodable {
    
    init?(json: Parameters) throws {
        guard let statusString = json["status"] as? String, let status = ResponseStatus(rawValue: statusString) else {
            throw SerializationError.missing("status")
        }
        self.status = status
        self.errorCode = json["error_code"] as? String
        self.message = json["message"] as? String
    }
    
}
