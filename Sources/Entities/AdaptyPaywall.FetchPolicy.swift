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

extension AdaptyPaywall.FetchPolicy: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case maxAge = "max_age"
        case reloadRevalidatingCacheData = "reload_revalidating_cache_data"
        case returnCacheDataElseLoad = "return_cache_data_else_load"
        case returnCacheDataIfNotExpiredElseLoad = "return_cache_data_if_not_expired_else_load"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case CodingKeys.reloadRevalidatingCacheData.rawValue:
            self = .reloadRevalidatingCacheData
        case CodingKeys.returnCacheDataElseLoad.rawValue:
            self = .returnCacheDataElseLoad
        case CodingKeys.returnCacheDataIfNotExpiredElseLoad.rawValue:
            self = .returnCacheDataIfNotExpiredElseLoad(maxAge: try container.decode(Double.self, forKey: .maxAge))
        default:
            self = .default
        }
    }
}