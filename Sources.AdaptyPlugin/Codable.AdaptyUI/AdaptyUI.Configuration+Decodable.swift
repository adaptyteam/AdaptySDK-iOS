//
//  AdaptyUI.Configuration+Decodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import AdaptyUI
import AdaptyUIBuider
import Foundation

extension AdaptyUI.Configuration: Decodable {
    private enum CodingKeys: String, CodingKey {
        case mediaCache = "media_cache"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            mediaCacheConfiguration: container.decodeIfPresent(AdaptyUIBuilder.MediaCacheConfiguration.self, forKey: .mediaCache)
        )
    }
}

extension AdaptyUIBuilder.MediaCacheConfiguration: Decodable {
    private enum CodingKeys: String, CodingKey {
        case memoryStorageTotalCostLimit = "memory_storage_total_cost_limit"
        case memoryStorageCountLimit = "memory_storage_count_limit"
        case diskStorageSizeLimit = "disk_storage_size_limit"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            memoryStorageTotalCostLimit: container.decodeIfPresent(Int.self, forKey: .memoryStorageTotalCostLimit) ?? AdaptyUIBuilder.MediaCacheConfiguration.default.memoryStorageTotalCostLimit,
            memoryStorageCountLimit: container.decodeIfPresent(Int.self, forKey: .memoryStorageCountLimit) ?? AdaptyUIBuilder.MediaCacheConfiguration.default.memoryStorageCountLimit,
            diskStorageSizeLimit: container.decodeIfPresent(UInt.self, forKey: .diskStorageSizeLimit) ?? AdaptyUIBuilder.MediaCacheConfiguration.default.diskStorageSizeLimit
        )
    }
}
