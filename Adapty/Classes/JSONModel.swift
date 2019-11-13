//
//  JSONModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 06/11/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

struct JSONModel {
    
    let data: Parameters
    
}

extension JSONModel: JSONCodable {
    
    init?(json: Parameters) throws {
        self.data = json
    }
    
}
