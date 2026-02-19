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
        class Legacy {}
        Legacy.productGroup = Object.create(null);
        Legacy.sections = Object.create(null);
        Legacy.selectProduct = function ({ productId, groupId }) {
             Legacy.productGroup[groupId] = { productId: productId, ["_" + productId.replace(/[^a-zA-Z0-9_]/g, '_')]: true };
             SDK.onSelectProduct({ productId: productId, paywallId: "legacy-paywal-id" });
        };
        Legacy.unselectProduct = function ({ groupId }) {
             delete Legacy.productGroup[groupId]
        };
        Legacy.purchaseSelectedProduct = function ({ groupId }) {
             const productId = Legacy.productGroup[groupId].productId;
             if (!productId) { return; }
             SDK.purchaseProduct({ productId: productId, paywallId: "legacy-paywal-id" });
        };
        Legacy.webPurchaseSelectedProduct = function ({ groupId, openIn }) {
             const productId = Legacy.productGroup[groupId].productId;
             if (!productId) { return; }
             SDK.webPurchaseProduct({ productId: productId, paywallId: "legacy-paywal-id", openIn: openIn });
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
