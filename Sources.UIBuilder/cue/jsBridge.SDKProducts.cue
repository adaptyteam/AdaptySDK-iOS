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
	[string]: #SDKProduct
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

// Store fields are added together. Nullable fields are present even when null;
// they are absent entirely from a metadata-only product.
#SDKLoadedProduct: {
	#SDKProductMetadata

	localizedDescription!: string
	localizedTitle!:       string
	isFamilyShareable!:    bool
	regionCode!:           null | string
	price!:                #SDKProductPrice
	subscription!:         null | #SDKProductSubscription
}

#SDKProductPrice: {
	amount!:          number
	currencyCode!:    string
	currencySymbol!:  null | string
	localizedString!: string
}

#SDKProductSubscription: {
	groupIdentifier!: string
	period!:          #SDKProductSubscriptionPeriod
	localizedPeriod!: null | string
	pricingTerms!:    #SDKProductSubscriptionPricingTerms
	offer!:           null | #SDKProductSubscriptionOffer
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
	id!:     null | string
	type!:   "introductory" | "promotional" | "win_back" | string
	phases!: [...#SDKProductSubscriptionOfferPhase]
}

#SDKProductSubscriptionOfferPhase: {
	price!:                    null | #SDKProductPrice
	paymentMode!:              "pay_as_you_go" | "pay_up_front" | "free_trial" | "unknown"
	period!:                   #SDKProductSubscriptionPeriod
	numberOfPeriods!:          int
	localizedPeriod!:          null | string
	localizedNumberOfPeriods!: null | string
}
