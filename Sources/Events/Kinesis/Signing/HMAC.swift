//
//  HMAC.swift
//  Adapty
//
//  Created by Aleksei Valiano on 10.10.2022.
//

import CommonCrypto
import Foundation

class HMAC {
    private let secretKey: [UInt8]
    private let algorithm: HMAC.Algorithm

    init(secret: String = "", algorithm: HMAC.Algorithm) {
        secretKey = [UInt8](secret.utf8)
        self.algorithm = algorithm
    }

    private init(secret: [UInt8], algorithm: HMAC.Algorithm) {
        secretKey = secret
        self.algorithm = algorithm
    }

    func authenticate(with text: String) -> [UInt8] {
        let textBytes: [UInt8] = [UInt8](text.utf8)
        let data = NSMutableData()
        data.append(textBytes, length: textBytes.count)
        var hmac = [UInt8](repeating: UInt8(0), count: Int(algorithm.digestLength))

        CCHmac(algorithm.cchmac, secretKey, secretKey.count, data.bytes, data.length, &hmac)

        return hmac
    }
}

extension HMAC {
    func authenticatedChain(with text: String) -> HMAC {
        let hmac = authenticate(with: text)
        return HMAC(secret: hmac, algorithm: algorithm)
    }
}

extension HMAC {
    enum Algorithm {
        case md5, sha1, sha224, sha256, sha384, sha512

        fileprivate var digestLength: Int32 {
            switch self {
            case .md5:
                return CC_MD5_DIGEST_LENGTH
            case .sha1:
                return CC_SHA1_DIGEST_LENGTH
            case .sha224:
                return CC_SHA224_DIGEST_LENGTH
            case .sha256:
                return CC_SHA256_DIGEST_LENGTH
            case .sha384:
                return CC_SHA384_DIGEST_LENGTH
            case .sha512:
                return CC_SHA512_DIGEST_LENGTH
            }
        }

        fileprivate var cchmac: CCHmacAlgorithm {
            switch self {
            case .md5:
                return CCHmacAlgorithm(kCCHmacAlgMD5)
            case .sha1:
                return CCHmacAlgorithm(kCCHmacAlgSHA1)
            case .sha256:
                return CCHmacAlgorithm(kCCHmacAlgSHA256)
            case .sha384:
                return CCHmacAlgorithm(kCCHmacAlgSHA384)
            case .sha512:
                return CCHmacAlgorithm(kCCHmacAlgSHA512)
            case .sha224:
                return CCHmacAlgorithm(kCCHmacAlgSHA224)
            }
        }
    }
}
