//
//  HTTPMetrics.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.09.2024
//

import Foundation

struct HTTPMetrics: Sendable, Hashable {
    let taskInterval: DateInterval
    let redirectCount: Int
    let transactions: [Transaction]
    let decoding: UInt64

    enum FetchType: String, Sendable {
        case cache
        case network

        init?(_ type: URLSessionTaskMetrics.ResourceFetchType) {
            switch type {
            case .localCache:
                self = .cache
            case .networkLoad:
                self = .network
            default:
                return nil
            }
        }
    }

    struct Transaction: Sendable, Hashable {
        let fetchType: FetchType?

        let queue: UInt64
        let dns: UInt64
        let connect: UInt64
        let sent: UInt64
        let wait: UInt64
        let received: UInt64

        let bytesSent: Int64
        let bytesReceived: Int64

        fileprivate var total: UInt64 { queue + dns + connect + sent + wait + wait }

        init(_ metrics: URLSessionTaskTransactionMetrics) {
            // https://developer.apple.com/documentation/foundation/urlsessiontasktransactionmetrics

            fetchType = FetchType(metrics.resourceFetchType)

            queue = toMillisecond(metrics.fetchStartDate, metrics.domainLookupStartDate) ?? toMillisecond(metrics.fetchStartDate, metrics.connectStartDate) ?? 0
            dns = toMillisecond(metrics.domainLookupStartDate, metrics.domainLookupEndDate) ?? 0
            connect = toMillisecond(metrics.connectStartDate, metrics.requestStartDate) ?? 0
            sent = toMillisecond(metrics.requestStartDate, metrics.requestEndDate) ?? 0
            wait = toMillisecond(metrics.requestEndDate, metrics.responseStartDate) ?? 0
            received = toMillisecond(metrics.responseStartDate, metrics.responseEndDate) ?? 0

            bytesSent = metrics.countOfRequestBodyBytesSent + metrics.countOfRequestHeaderBytesSent
            bytesReceived = metrics.countOfResponseBodyBytesReceived + metrics.countOfResponseHeaderBytesReceived

            func toMillisecond(_ from: Date?, _ to: Date?) -> UInt64? {
                guard let from, let to else { return nil }
                let delta = to.timeIntervalSince(from)
                guard delta >= 0.0 else { return nil }
                return UInt64(delta * 1000)
            }
        }
    }
}

extension HTTPMetrics {
    init(_ metrics: URLSessionTaskMetrics) {
        taskInterval = metrics.taskInterval
        redirectCount = metrics.redirectCount
        transactions = metrics.transactionMetrics.map(Transaction.init)
        decoding = 0
    }
}

extension HTTPMetrics: Encodable {
    private enum CodingKeys: String, CodingKey {
        case duration
        case redirect
        case transactions
        case decoding
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(taskInterval.duration * 1000), forKey: .duration)
        if redirectCount > 0 {
            try container.encode(redirectCount, forKey: .redirect)
        }
        if !transactions.isEmpty {
            try container.encode(transactions, forKey: .transactions)
        }
        if decoding > 0 {
            try container.encode(decoding, forKey: .decoding)
        }
    }
}

extension HTTPMetrics.Transaction: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case bytes

        case queue
        case dns
        case connect
        case sent
        case wait
        case received
    }

    private enum BytesCodingKeys: String, CodingKey {
        case bytesSent = "sent"
        case bytesReceived = "received"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fetchType?.rawValue, forKey: .type)

        if queue > 0 { try container.encode(queue, forKey: .queue) }
        if dns > 0 { try container.encode(dns, forKey: .dns) }
        if connect > 0 { try container.encode(connect, forKey: .connect) }
        if sent > 0 { try container.encode(sent, forKey: .sent) }
        if wait > 0 { try container.encode(wait, forKey: .wait) }
        if received > 0 { try container.encode(received, forKey: .received) }

        if bytesSent > 0 || bytesReceived > 0 {
            var container = container.nestedContainer(keyedBy: BytesCodingKeys.self, forKey: .bytes)
            try container.encode(bytesSent, forKey: .bytesSent)
            try container.encode(bytesReceived, forKey: .bytesReceived)
        }
    }
}

extension HTTPMetrics: CustomDebugStringConvertible {
    var debugDescription: String {
        var result = String(format: " - %.3fs", taskInterval.duration)
        if redirectCount > 0 {
            result += "\tredirects: \(redirectCount)"
        }
        if !transactions.isEmpty {
            result += "\t\t " + transactions.map { $0.debugDescription }.joined(separator: ", ")
        }
        if decoding > 1 {
            result += "\tdecoding: \(decoding)"
        } else if decoding == 1 {
            result += "\tdecoding: <1"
        }
        return result
    }
}

extension HTTPMetrics.Transaction: CustomDebugStringConvertible {
    var debugDescription: String {
        return switch fetchType {
        case .cache:
            "(local cache: \(milliseconds(total))):[\(bytes(bytesReceived))]"
        default:
            "(q: \(milliseconds(queue)), c: \(milliseconds(dns + connect)), u: \(milliseconds(sent)), w: \(milliseconds(wait)), d: \(milliseconds(received))):[u: \(bytes(bytesSent)), d: \(bytes(bytesReceived))]"
        }

        func milliseconds(_ i: UInt64) -> String {
            i > 0 ? String(i) : "-"
        }

        func bytes(_ bytes: Int64) -> String {
            ByteCountFormatter.string(fromByteCount: bytes, countStyle: .binary)
        }
    }
}
