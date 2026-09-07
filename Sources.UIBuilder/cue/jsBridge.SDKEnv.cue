package jsBridge

// Global environment snapshot installed before the flow scripts run.
// 
// JS: 
// 
// SDKEnv.localizationDirection
// SDKEnv.userLocales
// SDKEnv.placementId
// ...
// 
#SDKEnv: {
	platform!:      "ios"
	schemaVersion!: string
	sdkVersion!:    string

	localizationId!:        string
	localizationDirection!: "ltr" | "rtl"

	osName!:       string
	osVersion!:    string
	deviceVendor!: "Apple"
	deviceModel!:  string

	// Missing native values are omitted, not serialized as null.
	appBundleId?:      string
	appVersion?:       string
	appBuild?:         string
	appCurrentLocale?: string

	userLocales!: [...string]
	userUses24HourClock!: bool

	placementId!:            string
	placementVariationId!:   string
	placementVariationName?: string
	placementName!:          string
	placementABTestName!:    string
}
