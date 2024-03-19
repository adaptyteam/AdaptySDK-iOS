//
//  AdaptyPaywall.FetchPolicy.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.10.2023
//

import Foundation

extension AdaptyPaywall {
    public enum FetchPolicy {
        public static let `default`: Self = .reloadRevalidatingCacheData
        case reloadRevalidatingCacheData
        case returnCacheDataElseLoad
        case returnCacheDataIfNotExpiredElseLoad(maxAge: TimeInterval)
    }
}

extension AdaptyPaywall.FetchPolicy {
    func canReturn(_ data: VH<AdaptyPaywall>) -> Bool {
        switch self {
        case .reloadRevalidatingCacheData: return false
        case .returnCacheDataElseLoad: return true
        case let .returnCacheDataIfNotExpiredElseLoad(maxAge: maxAge):
            guard let time = data.time,
                  time.addingTimeInterval(maxAge) > Date()
            else { return false }
            return true
        }
    }
}

extension AdaptyPaywall.FetchPolicy: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case maxAge = "max_age"
    }

    enum CodingValues: String {
        case reloadRevalidatingCacheData = "reload_revalidating_cache_data"
        case returnCacheDataElseLoad = "return_cache_data_else_load"
        case returnCacheDataIfNotExpiredElseLoad = "return_cache_data_if_not_expired_else_load"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case CodingValues.reloadRevalidatingCacheData.rawValue:
            self = .reloadRevalidatingCacheData
        case CodingValues.returnCacheDataElseLoad.rawValue:
            self = .returnCacheDataElseLoad
        case CodingValues.returnCacheDataIfNotExpiredElseLoad.rawValue:
            self = try .returnCacheDataIfNotExpiredElseLoad(maxAge: container.decode(Double.self, forKey: .maxAge))
        default:
            self = .default
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .reloadRevalidatingCacheData:
            try container.encode(CodingValues.reloadRevalidatingCacheData.rawValue, forKey: .type)
        case .returnCacheDataElseLoad:
            try container.encode(CodingValues.returnCacheDataElseLoad.rawValue, forKey: .type)
        case let .returnCacheDataIfNotExpiredElseLoad(maxAge):
            try container.encode(CodingValues.returnCacheDataIfNotExpiredElseLoad.rawValue, forKey: .type)
            try container.encode(maxAge, forKey: .maxAge)
        }
    }
}
