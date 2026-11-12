package jsBridge

// Product dictionary keyed by productId.
// 
// JS: 
// 
// SDKProducts[productId].price.amount
// 
// Source: UIConfiguration/VC.FlowConstants.swift,
// UIState/JS/VS.JSState+setConstants.swift and UIState/AdaptyUIState.swift.
// 
#SDKProducts: {
	[key=string]: #SDKProduct & {
		flowProductId: key
	}
}

#SDKProduct: *#SDKProductMetadata | #SDKLoadedProduct

// Available from the flow configuration before store products are loaded.
#SDKProductMetadata: {
	flowProductId!:       string
	adaptyProductId!:     string
	adaptyAccessLevelId!: string
	adaptyProductType!:   #SDKAdaptyProductType
	paywallVariationId!:  string
	paywallName!:         string
}

#SDKAdaptyProductType: "weekly" |
                       "monthly" |
                       "two_months" |
                       "trimonthly" |
                       "semiannual" |
                       "annual" |
                       "lifetime" |
                       "consumable" |
                       "nonsubscriptions" |
                       "uncategorised" |
                       string

// Loaded products include store fields. regionCode and subscription are omitted
// when unavailable; metadata-only products contain none of the store fields.
#SDKLoadedProduct: {
	#SDKProductMetadata

	localizedDescription!: string
	localizedTitle!:       string
	isFamilyShareable!:    bool
	regionCode?:           string
	price!:                #SDKProductPrice
	subscription?:         #SDKProductSubscription
}

#SDKProductPrice: {
	amount!:          number
	currencyCode!:    string
	currencySymbol?:  string
	localizedString!: string
}

#SDKProductSubscription: {
	groupIdentifier!: string
	period!:          #SDKProductSubscriptionPeriod
	localizedPeriod?: string
	pricingTerms!:    #SDKProductSubscriptionPricingTerms
	offer?:           #SDKProductSubscriptionOffer
}

#SDKProductSubscriptionPeriod: {
	unit!:          "day" | "week" | "month" | "year" | "unknown"
	numberOfUnits!: int
}

#SDKProductSubscriptionPricingTerms: {
	billingPlanId!: "up_front" | "monthly" | string
	billingPrice!:  #SDKProductPrice
	billingPeriod!: #SDKProductSubscriptionPeriod
	commitmentInfo!: {
		price!:  #SDKProductPrice
		period!: #SDKProductSubscriptionPeriod
	}
}

#SDKProductSubscriptionOffer: {
	id?:     string
	type!:   "introductory" | "promotional" | "win_back" | string
	phases!: [...#SDKProductSubscriptionOfferPhase]
}

#SDKProductSubscriptionOfferPhase: {
	price?:                    #SDKProductPrice
	paymentMode!:              "pay_as_you_go" | "pay_up_front" | "free_trial" | "unknown"
	period!:                   #SDKProductSubscriptionPeriod
	numberOfPeriods!:          int
	localizedPeriod?:          string
	localizedNumberOfPeriods?: string
}
