//
//  Schema.LegacyScripts.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.12.2025.
//

import Foundation

extension Schema {
    enum LegacyScripts {
        static let actions = ##"""
        var Legacy = {
           productGroup: {},
           sections: {}
        };
        Legacy.selectProduct = function ({ productId, groupId }) {
             Legacy.productGroup[groupId] = { productId: productId, ["_" + productId.replace(/[^a-zA-Z0-9_]/g, '_')]: true };
             SDK.onSelectProduct({ productId: productId, paywallId: "legacy-paywall-id" });
        };
        Legacy.unselectProduct = function ({ groupId }) {
             delete Legacy.productGroup[groupId]
        };
        Legacy.purchaseSelectedProduct = function ({ groupId }) {
             const product = Legacy.productGroup[groupId];
             if (!product) { return; }
             SDK.purchaseProduct({ productId: product.productId, paywallId: "legacy-paywall-id" });
        };
        Legacy.webPurchaseSelectedProduct = function ({ groupId, openIn }) {
             const product = Legacy.productGroup[groupId];
             if (!product) { return; }
             SDK.webPurchaseProduct({ productId: product.productId, paywallId: "legacy-paywall-id", openIn: openIn });
        };
        Legacy.switchSection = function ({ sectionId, index }) {
             Legacy.sections[sectionId] = { index: index, ["_" + index]: true };
        };

        """##

        static func legacySelectProductScript(groupId: String = "group_A", productId: String) -> String {
            ##"Legacy.productGroup["\##(groupId)"] = { value: "\##(productId)", _\##(legacySafeProductId(productId)): true };"##
        }

        static func legacySelectSectionScript(sectionId: String, index: Int32) -> String {
            ##"Legacy.sections["\##(sectionId)"] = { value: \##(index), _\##(index): true };"##
        }

        static func legacyOpenDefaultScreen(screenId: ScreenType = "default") -> String {
            ##"SDK.openScreen({ instanceId: "\##(screenId)", type: "\##(screenId)", transitionId: "legacy-first-open" });"##
        }

        static func legacySafeProductId(_ str: String) -> String {
            let allowed = CharacterSet.alphanumerics
                .union(CharacterSet(charactersIn: "_"))

            var result = str.unicodeScalars.map { scalar in
                allowed.contains(scalar) ? String(scalar) : "_"
            }.joined()

            return result
        }
    }
}
