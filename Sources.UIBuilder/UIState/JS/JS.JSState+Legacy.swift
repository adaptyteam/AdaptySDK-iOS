//
//  JS.JSState+Legacy.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.12.2025.
//

import Foundation

extension VS.JSState {
    static let legacyActions = """
    class Legacy {}
    Legacy.productGroup = Object.create(null);
    Legacy.sections = Object.create(null);
    Legacy.selectProduct = function ( adaptyProductId, groupId ) {
          Legacy.productGroup[groupId] = adaptyProductId;
          SDK.selectProduct(adaptyProductId);
    };
    Legacy.unselectProduct = function ( groupId ) {
          delete Legacy.productGroup[groupId]
    };
    Legacy.purchaseSelectedProduct = function ( groupId ) {
         const productId = Legacy.productGroup[groupId];
         if (!productId) { return; }
         SDK.purchaseProduct( productId );
    };
    Legacy.webPurchaseSelectedProduct = function ( groupId, openIn ) {
         const productId = Legacy.productGroup[groupId];
         if (!productId) { return; }
         SDK.webPurchasePaywall( productId, openIn );
    };
    Legacy.switchSection = function ( sectionId, index ) {
         const i = parseInt(index, 10);
         Legacy.sections[sectionId] = i;
    };
    """
}
