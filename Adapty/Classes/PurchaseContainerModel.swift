//
//  PurchaseContainerModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation

public class PurchaseContainerModel: NSObject, JSONCodable, Codable {
    
    @objc public var developerId: String
    @objc public var variationId: String
    @objc public var revision: Int = 0
    @objc public var isWinback: Bool = false
    @objc public var products: [ProductModel] = []
    
    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let developerId = attributes?["developer_id"] as? String,
            let variationId = attributes?["variation_id"] as? String
        else {
            throw SerializationError.missing("developer_id, variation_id")
        }
        
        self.developerId = developerId
        self.variationId = variationId
        if let revision = attributes?["revision"] as? Int { self.revision = revision }
        if let isWinback = attributes?["is_winback"] as? Bool { self.isWinback = isWinback }
        
        guard let products = attributes?["products"] as? [Parameters] else {
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
    var products: [ProductModel] = []
    
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
        
        guard let meta = json["meta"] as? Parameters, let products = meta["products"] as? [Parameters] else {
            return
        }
        
        do {
            try products.forEach { (params) in
                if let product = try ProductModel(json: params) {
                    self.products.append(product)
                }
            }
        } catch {
            throw SerializationError.invalid("products in meta", meta)
        }
    }
    
}
