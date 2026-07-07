import Foundation

package enum MediaCacheHit: Sendable {
    case memory
    case disk
    case none

    init(_ cacheType: CacheType) {
        switch cacheType {
        case .memory: self = .memory
        case .disk:   self = .disk
        case .none:   self = .none
        }
    }
}
