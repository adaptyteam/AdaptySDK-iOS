//
//  String.sha256.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.10.2022.
//

import CommonCrypto
import Foundation

internal extension String {
    func sha256() -> String {
        let data = Data(utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
