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
    @objc public var isPromo: Bool = false
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
            throw SerializationError.missing("PurchaseContainerModel - developer_id, variation_id")
        }
        
        self.developerId = developerId
        self.variationId = variationId
        if let revision = attributes?["revision"] as? Int { self.revision = revision }
        if let isPromo = attributes?["is_promo"] as? Bool { self.isPromo = isPromo }
        
        guard let products = attributes?["products"] as? [Parameters] else {
            throw SerializationError.missing("PurchaseContainerModel - products")
        }
        
        var productsArray: [ProductModel] = []
        do {
            try products.forEach { (params) in
                if let product = try ProductModel(json: params) {
                    product.variationId = variationId
                    productsArray.append(product)
                }
            }
        } catch {
            throw SerializationError.invalid("PurchaseContainerModel - products", products)
        }
        self.products = productsArray
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PurchaseContainerModel else {
            return false
        }
        
        return self.developerId == object.developerId && self.variationId == object.variationId && self.revision == object.revision && self.isPromo == object.isPromo && self.products == object.products
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
            throw SerializationError.invalid("PurchaseContainersArray - purchase_containers", containers)
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
            throw SerializationError.invalid("PurchaseContainersArray - products in meta", meta)
        }
    }
    
}
