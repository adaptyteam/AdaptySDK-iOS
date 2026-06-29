package Adapty

import "list"

import "encoding/json"

#FallbackFileVersion: 11

fallback_file: {
	meta!: {
		version!: #FallbackFileVersion
		developer_ids!: [...string] & list.UniqueItems()
		response_created_at!: int @format(unix-time-millis)
		...
	}
	data!: {
		[string]: #PlacementVariations
	}
	ui_builder?: {
		[string]: #UIBuilderSchema
	}
	...
}

#PlacementMeta: {
	placement!: {
		developer_id!:                  string
		audience_name!:                 string
		placement_audience_version_id!: string
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
}

#Placement: {
	meta!: #PlacementMeta
	data!: #FlowData | #OnboardingData
}

#VariationData: {
	variation_id!: string
	cross_placement_info?: null | {
		placement_with_variation_map!:
			[string]: string
	}
	weight!: int
}

#FlowData: {
	#VariationData
	flow_id!:         string
	flow_name!:       string
	flow_version_id?: null | string
	remote_configs?: [...#RemouteConfig]
	variations!: [...#PaywallData]
	ui_schema?: #FlowLayoutsConfiguration
	...
	if ui_schema != _|_ {
		flow_version_id!: string
	}

	onboarding_id?: _|_ // иначе нельзя отличить от #OnboardingData
}

#OnboardingData: {
	#VariationData
	onboarding_id!:   string
	onboarding_name!: string
	remote_config?:   #RemouteConfig
	onboarding_builder!: {
		config_url!: string
	}
	...

	flow_id?: _|_ // иначе нельзя отличить от #FlowData
}

#RemouteConfig: {
	lang!: string
	data!: string & json.Valid
}

#PaywallData: {
	...
}

#FlowLayoutsConfiguration: {
	layouts!: [...#FlowLayout]
	grids!: [...#FlowLayoutsGrid]
}

#FlowLayout: {
	flow_layout_id!: string
}

#FlowLayoutsGrid: {
	platforms?: "all" | [...#SDKNativePlatformIdentifier]
	devices?: "all" | [...#DeviceTypeIdentifier]
	custom_id?: string

	h_breakpoints?: [...int & >0] & list.UniqueItems() & list.IsSorted(list.Ascending)
	v_breakpoints?: [...int & >0] & list.UniqueItems() & list.IsSorted(list.Ascending)

	// hidden computed values
	_hCount: [if h_breakpoints != _|_ {len(h_breakpoints)}, 0][0]
	_vCount: [if v_breakpoints != _|_ {len(v_breakpoints)}, 0][0]
	_cellCount: (_hCount + 1) * (_vCount + 1)

	cells: [...int & >=0] & list.MinItems(_cellCount) & list.MaxItems(_cellCount)
}

#UIBuilderSchema: {
	...
}

#SDKNativePlatformIdentifier: "ios" | "android"
#DeviceTypeIdentifier:        "phone" | "tab" | string
