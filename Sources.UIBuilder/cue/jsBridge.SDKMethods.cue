package jsBridge

#SDKMethods: {
    
    // 
    // CUE rule:
    // <js-method-name>: {
    //     arguments!: [<argument types>]
    // }
    //
    // JS code:
    // SDK.<js-method-name>(<argument values>);
    // 
    
    log: {   
		// A string is shorthand for {message: string}. 
		// Native code also coerces non-object JS values to strings.
		arguments!: [string] | [#LogParameters]
	}
	
	openUrl: {
		arguments!: [#OpenUrlParameters]
	}

	userCustomAction: {
		arguments!: [#UserCustomActionParameters]
	}

	purchaseProduct: {
		arguments!: [#PurchaseProductParameters]
	}

	webPurchaseProduct: {
		arguments!: [#WebPurchaseProductParameters]
	}

	restorePurchases: {
		arguments!: [] | [#RestorePurchasesParameters]
	}

	closeAll: {
		arguments!: []
	}

	onSelectProduct: {
		arguments!: [#OnSelectProductParameters]
	}

	openScreen: {
		arguments!: [#OpenScreenParameters]
	}
	
	closeScreen: {
		arguments!: [#CloseScreenParameters]
	}

	changeFocus: {
		// An absent id clears focus; the whole argument may be omitted.
		arguments!: [] | [#ChangeFocusParameters]
	}

	setTimer: {
		arguments!: [#SetTimerParameters]
	}

	moveScroll: {
		arguments!: [#MoveScrollParameters]
	}

	showAppRate: {
		arguments!: []
	}
	
	showAlertDialog: {
		arguments!: [#ShowAlertDialogParameters]
	}
	
	showRequestPermission: {
		arguments!: [#ShowRequestPermissionParameters]
	}

	sendEvents: {
		arguments!: [#SendEventsParameters]
	}
	
	sendAnalyticsEvent: {
		arguments!: [#SendAnalyticsEventParameters]
	}
}

// SDK.log(...)

#LogParameters: {
	message?: string
	level?:   *"debug" | "error" | "warn" | "info" | "verbose"
}

// SDK.openUrl(...)

#OpenUrlParameters: {
	openIn?: *"browser_out_app" | "browser_in_app"
	url?:    string
	
	if url == _|_ {
		stringId!: string
	}
}

// SDK.userCustomAction(...)

#UserCustomActionParameters: {
	userCustomId!: string
}

// SDK.purchaseProduct(...)

#PurchaseProductParameters: {
	productId!: string
	callback?:  #PurchaseProductCallback
}

#PurchaseProductCallback: {
    arguments!: [#PurchaseProductResponse]
}

#PurchaseProductResponse: {
    productId!: string
    result!:    #PurchaseResult
}

#PurchaseResult: "fail" | 
                 "userCanceled" | 
                 "success" | 
                 "pending"

// SDK.webPurchaseProduct(...)

#WebPurchaseProductParameters: {
	productId!: string
	openIn?:    *"browser_out_app" | "browser_in_app"
	callback?:  #PurchaseProductCallback
}

// SDK.restorePurchases(...)

#RestorePurchasesParameters: {
	callback?: #RestorePurchasesCallback
}

#RestorePurchasesCallback: {
    arguments!: [#RestorePurchasesResponse]
}

#RestorePurchasesResponse: {
    result!: #RestorePurchasesResult
}

#RestorePurchasesResult: "fail" | "success"


// SDK.onSelectProduct(...)

#OnSelectProductParameters: {
	productId!: string
}

// SDK.openScreen(...)

#OpenScreenParameters: {
	type!:         string 
	instanceId!:   string
	transitionId!: string
	navigatorId?:  *"default" | string
	
	// Dot-separated path. Native code drops empty components; absent means [].
	contextPath?: string
}

// SDK.closeScreen(...)

#CloseScreenParameters: {
	navigatorId?:  *"default" | string
	transitionId?: *"on_disappear" | string
}

// SDK.changeFocus(...)

#ChangeFocusParameters: {
	id?: string
}

// SDK.setTimer(...)

#SetTimerParameters: {
	id!:       string
	endAt?:    number // Unix timestamp in milliseconds
	callback?: #TimerCallback

	if endAt == _|_ {
		duration!: number // in seconds
		behavior?: *"continue" | "restart" | "persisted" | "custom"
	}
}

#TimerCallback: {
    arguments!: [#TimerResponse]
}

#TimerResponse: {
    timerId: string
}

// SDK.moveScroll(...)

#MoveScrollParameters: {
	instanceId!: string
	kind!:       "content" | "footer"
	value!:      "start" | "end"
}

// SDK.showAlertDialog(...)

#ShowAlertDialogParameters: {
    title?:   string
    message?: string
    actions?: [...#ShowAlertDialogButtonParameters]
	callback?:  #ShowAlertDialogCallback
}

#ShowAlertDialogButtonParameters: {
    title?:      string
    style?:    *"default" | "cancel" | "destructive"
    actionId?: string 

    if title != _|_ {
        actionId: *title | string
    }
}

#ShowAlertDialogCallback: {
    arguments!: [#ShowAlertDialogResponse]
}

#ShowAlertDialogResponse: {
    actionId: null | string
}

// SDK.showRequestPermission(...)
 
#ShowRequestPermissionParameters: {
    permission?: string
    customArgs?: { [string]: string }
	callback?: #ShowRequestPermissionCallback
}

#ShowRequestPermissionCallback: {
    arguments!: [#ShowRequestPermissionResponse]
}

#ShowRequestPermissionResponse: {
    permission: null | string
    customArgs?: { [string]: string }
    result!: bool
    detailResult: null | string
}

// SDK.sendEvents(...)

#SendEventsParameters: {
	instanceId?: string
	events!: [string, ...string]
}

// SDK.sendAnalyticsEvent(...)

#SendAnalyticsEventParameters: {
	name!:            string
	instanceId?:      string
	isBackendEvent?:  *true | bool
	isCustomerEvent?: *false | bool
	// UIState forwards the parameter dictionary, including these named fields.
	// This covers JSON-compatible values; downstream analytics may filter them.
	[string]: #JSValue
}