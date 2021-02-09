//
//  PaywallModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation

public class PaywallModel: NSObject, JSONCodable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case developerId
        case variationId
        case revision
        case isPromo
        case products
        case visualPaywall
        case customPayloadString
        case abTestName
        case name
    }
    
    @objc public var developerId: String
    @objc public var variationId: String
    @objc public var revision: Int = 0
    @objc public var isPromo: Bool = false
    @objc public var products: [ProductModel] = []
    @objc public var visualPaywall: String?
    @objc public var customPayloadString: String?
    @objc public lazy var customPayload: Parameters? = {
        if let data = customPayloadString?.data(using: .utf8), let customPayload = try? JSONSerialization.jsonObject(with: data, options: []) as? Parameters {
            return customPayload
        }
        return nil
    }()
    @objc public var abTestName: String?
    @objc public var name: String?
    
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
            throw AdaptyError.missingParam("PaywallModel - developer_id, variation_id")
        }
        
        self.developerId = developerId
        self.variationId = variationId
        if let revision = attributes?["revision"] as? Int { self.revision = revision }
        if let isPromo = attributes?["is_promo"] as? Bool { self.isPromo = isPromo }
        if let visualPaywall = attributes?["visual_paywall"] as? String { self.visualPaywall = visualPaywall }
        if let customPayloadString = attributes?["custom_payload"] as? String { self.customPayloadString = customPayloadString }
        self.abTestName = attributes?["ab_test_name"] as? String
        self.name = attributes?["paywall_name"] as? String
        
        guard let products = attributes?["products"] as? [Parameters] else {
            throw AdaptyError.missingParam("PaywallModel - products")
        }
        
        var productsArray: [ProductModel] = []
        do {
            try products.forEach { (params) in
                if let product = try ProductModel(json: params) {
                    productsArray.append(product)
                }
            }
        } catch {
            throw AdaptyError.invalidProperty("PaywallModel - products", products)
        }
        self.products = productsArray
        for product in self.products {
            product.variationId = self.variationId
            product.paywallABTestName = self.abTestName
            product.paywallName = self.name
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PaywallModel else {
            return false
        }
        
        return self.developerId == object.developerId && self.variationId == object.variationId && self.revision == object.revision && self.isPromo == object.isPromo && self.products == object.products && self.visualPaywall == object.visualPaywall && self.customPayloadString == object.customPayloadString && self.abTestName == object.abTestName && self.name == object.name
    }
    
}

class PaywallsArray: JSONCodable {
    
    var paywalls: [PaywallModel] = []
    var products: [ProductModel] = []
    
    required init?(json: Parameters) throws {
        guard let paywalls = json["data"] as? [Parameters] else {
            return
        }
        
        do {
            try paywalls.forEach { (params) in
                if let paywall = try PaywallModel(json: params) {
                    self.paywalls.append(paywall)
                }
            }
        } catch {
            throw AdaptyError.invalidProperty("PaywallsArray - paywalls", paywalls)
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
            throw AdaptyError.invalidProperty("PaywallsArray - products in meta", meta)
        }
    }
    
}
