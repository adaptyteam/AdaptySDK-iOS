//
//  ResponseErrorModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

struct ResponseErrorModel: JSONCodable {
    
    let detail: String
    let status: String
    let source: Parameters
    let code: Int
    
    init?(json: Parameters) throws {
        guard
            let detail = json["detail"] as? String,
            let status = json["code"] as? String,
            let source = json["source"] as? Parameters,
            let codeString = json["status"] as? String,
            let code = Int(codeString)
        else {
            throw SerializationError.missing("detail, status, source, code")
        }
        
        self.detail = detail
        self.status = status
        self.source = source
        self.code = code
    }
    
    var description: String {
        return "Status: \(status). Details: \(detail)"
    }
    
}

struct ResponseErrorsArray: JSONCodable {
    
    var errors: [ResponseErrorModel] = []
    
    init?(json: Parameters) throws {
        guard let errors = json["errors"] as? [Parameters] else {
            return
        }
        
        do {
            try errors.forEach { (params) in
                if let error = try ResponseErrorModel(json: params) {
                    self.errors.append(error)
                }
            }
        } catch {
            throw SerializationError.invalid("errors", errors)
        }
    }
    
}
