//
//  HTTPEncodableRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

protocol HTTPEncodableRequest: HTTPDataRequest, Encodable {}

extension HTTPEncodableRequest {
    func getData(configuration: HTTPConfiguration) throws -> Data? {
        let encoder = (configuration as? HTTPCodableConfiguration)?.encoder ?? JSONEncoder()
        return try encoder.encode(AnyEncodable(self))
    }
}
