//
//  JSONModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 06/11/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

struct JSONModel: JSONCodable {
    
    let data: Parameters
    
    init?(json: Parameters) throws {
        self.data = json
    }
    
}

struct JSONAttributedModel: JSONCodable {
    
    let data: Parameters
    
    init?(json: Parameters) throws {
        let attributes: Parameters!
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        self.data = attributes
    }
    
}
