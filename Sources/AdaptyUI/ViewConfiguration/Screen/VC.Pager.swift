//
//  VC.Pager.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Pager {}
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func pager(_: AdaptyUI.ViewConfiguration.Pager) -> AdaptyUI.Pager {
        .init(
        )
    }
}

extension AdaptyUI.ViewConfiguration.Pager: Decodable {
    enum CodingKeys: String, CodingKey {
        case delete_me
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
        )
    }
}
