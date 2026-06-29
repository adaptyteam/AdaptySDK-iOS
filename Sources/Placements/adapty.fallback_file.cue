package Adapty

import "list"

import "net"

import "encoding/json"

#FallbackFileVersion: 11

fallback_file: {
	meta!: {
		version!: #FallbackFileVersion
		developer_ids!: [...#Identifier] & list.UniqueItems()
		response_created_at!: int @format(unix-time-millis)
		...
	}
	data!: {
		[string]: #PlacementVariations
	}
	ui_builder?: null | {
		[string]: #UIBuilderSchema | #UIBuilderLegacySchema
	}
	...
}

#PlacementMeta: {
	placement!: {
		developer_id!:                  #Identifier
		audience_name!:                 string
		placement_audience_version_id!: #Identifier
		revision!:                      int
		ab_test_name!:                  string
		is_tracking_purchases?:         *false | bool
		...
	}
	response_created_at?: int @format(unix-time-millis)
	...
}

#PlacementVariations: {
	meta!: #PlacementMeta
	data!: [...#FlowData | #OnboardingData]
	...
}

#Placement: {
	meta!: #PlacementMeta
	data!: #FlowData | #OnboardingData
	...
}

#VariationData: {
	variation_id!: #Identifier
	cross_placement_info?: null | {
		placement_with_variation_map!:
			[string]: string
	}
	weight!: int & >=0
}

#FlowData: {
	#VariationData
	flow_id!:         #Identifier
	flow_name!:       string
	flow_version_id?: null | #Identifier
	remote_configs?: null | [...#RemouteConfig]
	variations!: [...#PaywallData]
	ui_schema?: null | #FlowLayoutsConfiguration
	...
	_uiSchema: [if ui_schema != _|_ {ui_schema}, null][0]
	if _uiSchema != null {
		flow_version_id!: #Identifier
	}

	onboarding_id?: _|_ // иначе нельзя отличить от #OnboardingData
}

#OnboardingData: {
	#VariationData
	onboarding_id!:   #Identifier
	onboarding_name!: string
	remote_config?:   null | #RemouteConfig
	onboarding_builder!: {
		config_url!: #URL
	}
	...

	flow_id?: _|_ // иначе нельзя отличить от #FlowData
}

#RemouteConfig: {
	lang!: string
	data!: string & json.Valid
	...

	// hidden computed values for validate json-string
	_dataIsObject: json.Validate(data, {...})
}

#PaywallData: {
	paywall_id!:       #Identifier
	paywall_name!:     string
	variation_id!:     #Identifier
	web_purchase_url?: null | #URL
	products!: [...#PaywallProductData] //& list.MinItems(1)
	...
}

#PaywallProductData: {
	adapty_product_id!:             #Identifier
	access_level_id!:               #Identifier
	vendor_product_id!:             #Identifier
	flow_product_id?:               null | #Identifier
	win_back_offer_id?:             null | #Identifier
	promotional_offer_eligibility?: *true | bool
	promotional_offer_id?:          null | #Identifier
	product_type!:                  string
	...
}

#FlowLayoutsConfiguration: {
	layouts!: [...#FlowLayout]
	grids!: [...#FlowLayoutsGrid]
}

#FlowLayout: {
	flow_layout_id!: #Identifier
	...
}

#FlowLayoutsGrid: {
	platforms?: "all" | [...#SDKNativePlatformIdentifier]
	devices?: "all" | [...#DeviceTypeIdentifier]
	custom_id?: null | #Identifier

	h_breakpoints?: [...int & >0] & list.UniqueItems() & list.IsSorted(list.Ascending)
	v_breakpoints?: [...int & >0] & list.UniqueItems() & list.IsSorted(list.Ascending)

	// hidden computed values
	_hCount: [if h_breakpoints != _|_ {len(h_breakpoints)}, 0][0]
	_vCount: [if v_breakpoints != _|_ {len(v_breakpoints)}, 0][0]
	_cellCount: (_hCount + 1) * (_vCount + 1)

	cells: [...int & >=0] & list.MinItems(_cellCount) & list.MaxItems(_cellCount)
}

#UIBuilderSchema: {
	format!: #UIBulderSchemaVersion
	assets?: [...{...}]
	localizations?: [...{...}]
	default_localization?: string
	behavior?: {...}
	templates?: {...}
	navigators?: {...}
	screens!: {...}
	scripts!: [...{...}]
}

#UIBuilderLegacySchema: {
	format!:            #UIBulderLegacySchemaVersion
	template_id!:       #Identifier
	template_revision?: int
	assets?: [...{...}]
	localizations?: [...{...}]
	default_localization?: string
	products?: {...}
	styles!: {...}
}

#SDKNativePlatformIdentifier: "ios" | "android"
#DeviceTypeIdentifier:        "phone" | "tab" | string

#Identifier:                  string & =~"\\S"
#URL:                         string & net.AbsURL & =~"^https?://"
#Version:                     string & =~"^[0-9]+(\\.[0-9]+){0,2}(-[A-Za-z0-9._]+)?$"
#UIBulderSchemaVersion:       string & =~"^([5-9]|[1-9][0-9]+)(\\.[0-9]+){0,2}(-[A-Za-z0-9._]+)?$"
#UIBulderLegacySchemaVersion: string & =~"^4(\\.[0-9]+){0,2}(-[A-Za-z0-9._]+)?$"
