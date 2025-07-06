//
//  String+CryptoKit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.07.2025
//

import Foundation
import CryptoKit

extension String {
    @inlinable
    var md5: Insecure.MD5.Digest {
        Insecure.MD5.hash(data: Data(utf8))
    }
    
    @inlinable
    var sha256: SHA256.Digest {
        SHA256.hash(data: Data(utf8))
    }
}

extension Digest {
    @inlinable
    var hexString: String {
        map{ String(format: "%02hhx", $0) }.joined()
    }
}
