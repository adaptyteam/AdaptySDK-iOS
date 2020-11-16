//
//  JSONCodable.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 06/11/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

protocol JSONCodable {
    init?(json: Parameters) throws
}
