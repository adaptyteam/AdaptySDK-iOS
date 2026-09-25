//
//  Request.GetPendingStoreMessageTypes.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 18.08.2026.
//

#if os(iOS) || os(visionOS)

import Adapty
import Foundation

extension Request {
    @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
    struct GetPendingStoreMessageTypes: AdaptyPluginRequest {
        static let method = "get_pending_store_message_types"

        func execute() async throws -> AdaptyJsonData {
            let types = await Adapty.getPendingStoreMessageTypes()
            return .success(types)
        }
    }
}

#endif
