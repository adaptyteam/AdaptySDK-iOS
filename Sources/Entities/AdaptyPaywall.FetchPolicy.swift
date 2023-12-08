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
    }
}

extension AdaptyPaywall.FetchPolicy {
    func canReturn(_ data: VH<AdaptyPaywall>) -> Bool {
        switch self {
        case .reloadRevalidatingCacheData: return false
        case .returnCacheDataElseLoad: return true
        }
    }
}

extension AdaptyPaywall.FetchPolicy: Codable {
    enum CodingValues: String {
        case reloadRevalidatingCacheData = "reload_revalidating_cache_data"
        case returnCacheDataElseLoad = "return_cache_data_else_load"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        switch try container.decode(String.self) {
        case CodingValues.reloadRevalidatingCacheData.rawValue:
            self = .reloadRevalidatingCacheData
        case CodingValues.returnCacheDataElseLoad.rawValue:
            self = .returnCacheDataElseLoad
        default:
            self = .default
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .reloadRevalidatingCacheData:
            try container.encode(CodingValues.reloadRevalidatingCacheData.rawValue)
        case .returnCacheDataElseLoad:
            try container.encode(CodingValues.returnCacheDataElseLoad.rawValue)
        }
    }
}
