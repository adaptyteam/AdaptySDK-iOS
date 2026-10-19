package jsBridge

//
// JS code:
// 
// 
// 
// handleSDKEvent(sdkEvent) {
//   let eventId = sdkEvent.id;
//   switch (sdkEvent.name) {
//      case "applicationMsg": break;
//      case "customElementMsg": break;
//      case "productsLoaded": break;
//      case ...
//   }
// }
// 
// 
// 
// CUE rule:
// <js-method-name>: {
//     arguments!: [<argument types>]
// }
//
// JS code:
// SDK.<js-method-name>(<argument values>);
// 
#HandleSDKEvent: {
    arguments!:[#SDKEvent]
}

#SDKEvent: #ProductsLoadedMessage | 
           #PurchaseMessage | 
           #RestorePurchasesMessage |
           #ApplicationMessage
    
#ProductsLoadedMessage: {
    id!: string
    name!: "productsLoaded"
}

#PurchaseMessage: {
    id!: string
    name!: "willPurchase" | "didPurchase"
    productId!: string

    if name == "didPurchase" {
        result!: #PurchaseResult
    }
}

#RestorePurchasesMessage: {
    id!: string
    name!: "willRestorePurchases" | "didRestorePurchases"

    if name == "didRestorePurchases" {
        result!: #RestorePurchasesResult
    }
}

#ApplicationMessage: {
    id!: string
    name!: "applicationMsg" | "customElementMsg"
    screen?: #ScreenInstance
    element?: #CustomElementInstance
    payload!: #JSObject
}

#CustomElementInstance: {
	id!:   string
	type!: string
}