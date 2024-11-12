//
//  AdaptyUI.Configuration+Decodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.Configuration: Decodable {
    private enum Codingkey: String, CodingKey {
        case mediaCache = "media_cache"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Codingkey.self)
        try self.init(
            mediaCacheConfiguration: container.decode(AdaptyUI.MediaCacheConfiguration.self, forKey: .mediaCache)
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.MediaCacheConfiguration: Decodable {
    private enum Codingkey: String, CodingKey {
        case memoryStorageTotalCostLimit = "memory_storage_total_cost_limit"
        case memoryStorageCountLimit = "memory_storage_count_limit"
        case diskStorageSizeLimit = "disk_storage_size_limit"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Codingkey.self)

        try self.init(
            memoryStorageTotalCostLimit: container.decode(Int.self, forKey: .memoryStorageTotalCostLimit),
            memoryStorageCountLimit: container.decode(Int.self, forKey: .memoryStorageCountLimit),
            diskStorageSizeLimit: container.decode(UInt.self, forKey: .diskStorageSizeLimit)
        )
    }
}
