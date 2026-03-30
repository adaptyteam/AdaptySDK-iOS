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
        """##

        static func legacySelectProductScript(groupId: String = "group_A", productId: String) -> String {
            ##"Legacy.productGroup["\##(groupId)"] = "\##(productId)";"##
        }

        static func legacySelectSectionScript(sectionId: String, index: Int32) -> String {
            ##"Legacy.sections["\##(sectionId)"] = \##(index);"##
        }

        static func legacyOpenDefaultScreen(screenId: ScreenType = "default") -> String {
            ##"SDK.openScreen({ instanceId: "\##(screenId)", type: "\##(screenId)", transitionId: "legacy-first-open" });"##
        }
    }
}
