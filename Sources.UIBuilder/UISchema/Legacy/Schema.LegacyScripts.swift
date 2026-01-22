//
//  Schema.LegacyScripts.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.12.2025.
//

import Foundation

extension Schema {
    enum LegacyScripts {
        static let actions = """
        class Legacy {}
        Legacy.productGroup = Object.create(null);
        Legacy.sections = Object.create(null);
        Legacy.selectProduct = function ({ productId, groupId }) {
              Legacy.productGroup[groupId] = productId;
              SDK.onSelectProduct({ productId: productId });
        };
        Legacy.unselectProduct = function ({ groupId }) {
              delete Legacy.productGroup[groupId]
        };
        Legacy.purchaseSelectedProduct = function ({ groupId }) {
             const productId = Legacy.productGroup[groupId];
             if (!productId) { return; }
             SDK.purchaseProduct({ productId: productId });
        };
        Legacy.webPurchaseSelectedProduct = function ({ groupId, openIn }) {
             const productId = Legacy.productGroup[groupId];
             if (!productId) { return; }
             SDK.webPurchaseProduct({ productId: productId, openIn: openIn });
        };
        Legacy.switchSection = function ({ sectionId, index }) {
             Legacy.sections[sectionId] = index;
        };
        """

        static func legacySelectProductScript(groupId: String = "group_A", productId: String) -> String {
            "Legacy.productGroup[\"\(groupId)\"] = \"\(productId)\";"
        }

        static func legacyOpenScreen(screenId: ScreenIdentifier = "default") -> String {
            "SDK.openScreen({ screenId: \"\(screenId)\" })"
        }
    }
}
