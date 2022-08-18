//
//  ProductsArray.swift
//  Adapty
//
//  Created by Alexey Valiano on 10.08.2022.
//

import Foundation

class ProductsArray: JSONCodable {
    var products: [ProductModel] = []

    required init?(json: Parameters) throws {
        guard let data = json["data"] as? [Parameters] else {
            return
        }

        do {
            try data.forEach { params in
                if let product = try ProductModel(json: params) {
                    self.products.append(product)
                }
            }
        } catch {
            throw AdaptyError.invalidProperty("ProductsArray - products", data)
        }
    }
}
