//
//  PurchaseContainerModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation

public class PurchaseContainerModel: NSObject, JSONCodable {
    
    public var developerId: String
    public var variationId: String
    public var revision: Int?
    public var isWinback: Bool?
    public var products: [ProductModel] = []
    
    required init?(json: Parameters) throws {
        guard
            let developerId = json["purchase_container_developer_id"] as? String,
            let variationId = json["variation_id"] as? String
        else {
            throw SerializationError.missing("purchase_container_developer_id, variation_id")
        }
        
        self.developerId = developerId
        self.variationId = variationId
        self.revision = json["purchase_container_revision"] as? Int
        self.isWinback = json["is_winback"] as? Bool
        
        guard let products = json["products"] as? [Parameters] else {
            throw SerializationError.missing("products")
        }
        
        var productsArray: [ProductModel] = []
        do {
            try products.forEach { (params) in
                if let product = try ProductModel(json: params) {
                    productsArray.append(product)
                }
            }
        } catch {
            throw SerializationError.invalid("products", products)
        }
        self.products = productsArray
    }
    
}

class PurchaseContainersArray: JSONCodable {
    
    var containers: [PurchaseContainerModel] = []
    
    required init?(json: Parameters) throws {
        guard let containers = json["data"] as? [Parameters] else {
            return
        }
        
        do {
            try containers.forEach { (params) in
                if let container = try PurchaseContainerModel(json: params) {
                    self.containers.append(container)
                }
            }
        } catch {
            throw SerializationError.invalid("purchase_containers", containers)
        }
    }
    
}
