//
//  Request.ShowStoreMessage.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 18.08.2026.
//

#if os(iOS) || os(visionOS)

import Adapty
import Foundation

extension Request {
    @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
    struct ShowStoreMessage: AdaptyPluginRequest {
        static let method = "show_store_messages"
        let filter: Set<AdaptyStoreMessageType>?

        enum CodingKeys: CodingKey {
            case filter
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.showStoreMessages(for: filter)
            return .success()
        }
    }
}

#endif
