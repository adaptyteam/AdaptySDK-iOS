import Foundation

struct MediaCacheConfiguration: Sendable {
    var memoryStorageTotalCostLimit: Int
    var memoryStorageCountLimit: Int
    var diskStorageSizeLimit: UInt

    init(
        memoryStorageTotalCostLimit: Int,
        memoryStorageCountLimit: Int,
        diskStorageSizeLimit: UInt
    ) {
        self.memoryStorageTotalCostLimit = memoryStorageTotalCostLimit
        self.memoryStorageCountLimit = memoryStorageCountLimit
        self.diskStorageSizeLimit = diskStorageSizeLimit
    }

    static let `default` = MediaCacheConfiguration(
        memoryStorageTotalCostLimit: 100 * 1024 * 1024,
        memoryStorageCountLimit: .max,
        diskStorageSizeLimit: 100 * 1024 * 1024
    )
}
