//
//  ProductModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation
import StoreKit

public class ProductModel: NSObject, JSONCodable {
    
    public var vendorProductId: String
    public var title: String
    public var skProduct: SKProduct?
    
    required init?(json: Parameters) throws {
        guard
            let vendorProductId = json["vendor_product_id"] as? String,
            let title = json["title"] as? String
        else {
            throw SerializationError.missing("vendorProductId, title")
        }
        
        self.vendorProductId = vendorProductId
        self.title = title
    }
    
}
