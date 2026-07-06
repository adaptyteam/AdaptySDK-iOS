//
//  Request.AdaptyUIOpenUrl.swift
//  AdaptyPlugin
//

import Adapty
import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIOpenUrl: AdaptyPluginRequest {
        static let method = "adapty_ui_open_url"

        let url: URL
        let presentation: AdaptyWebPresentation

        enum CodingKeys: String, CodingKey {
            case url
            case presentation = "open_in"
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            url = try container.decode(URL.self, forKey: .url)
            presentation = try container.decodeIfPresent(AdaptyWebPresentation.self, forKey: .presentation) ?? .externalBrowser
        }

        func execute() async throws -> AdaptyJsonData {
            await AdaptyUI.Plugin.openURL(url, in: presentation)
            return .success()
        }
    }
}
