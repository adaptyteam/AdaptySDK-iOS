//
//  PaywallModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation

public class PaywallModel: NSObject, JSONCodable, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "developerId"
        case variationId
        case revision
        case products
        case customPayloadString
        case abTestName
        case name
    }

    @objc public var id: String
    @objc public var variationId: String
    @objc public var revision: Int = 0
    @objc public var products: [ProductModel] = []
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

        self.id = developerId
        self.variationId = variationId
        if let revision = attributes?["revision"] as? Int { self.revision = revision }
        if let customPayloadString = attributes?["custom_payload"] as? String { self.customPayloadString = customPayloadString }
        abTestName = attributes?["ab_test_name"] as? String
        name = attributes?["paywall_name"] as? String

        guard let products = attributes?["products"] as? [Parameters] else {
            throw AdaptyError.missingParam("PaywallModel - products")
        }

        var productsArray: [ProductModel] = []
        do {
            try products.forEach { params in
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
            product.paywallABTestName = abTestName
            product.paywallName = name
        }
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PaywallModel else {
            return false
        }

        return
            id == object.id &&
            variationId == object.variationId &&
            revision == object.revision &&
            products == object.products &&
            customPayloadString == object.customPayloadString &&
            abTestName == object.abTestName &&
            name == object.name
    }
}


