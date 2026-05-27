import Foundation

package struct MediaCacheConfiguration: Sendable {
    package var memoryStorageTotalCostLimit: Int
    package var memoryStorageCountLimit: Int
    package var diskStorageSizeLimit: UInt

    package init(
        memoryStorageTotalCostLimit: Int,
        memoryStorageCountLimit: Int,
        diskStorageSizeLimit: UInt
    ) {
        self.memoryStorageTotalCostLimit = memoryStorageTotalCostLimit
        self.memoryStorageCountLimit = memoryStorageCountLimit
        self.diskStorageSizeLimit = diskStorageSizeLimit
    }

    package static let `default` = MediaCacheConfiguration(
        memoryStorageTotalCostLimit: 100 * 1024 * 1024,
        memoryStorageCountLimit: .max,
        diskStorageSizeLimit: 100 * 1024 * 1024
    )
}
