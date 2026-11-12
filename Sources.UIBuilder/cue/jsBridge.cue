package jsBridge

#JSSimpleValue: null | bool | number | string
#JSValue: #JSSimpleValue | #JSArray | #JSObject
#JSArray: [...#JSValue]
#JSObject: { [string]: #JSValue }

//
// JS code:
//
// foo(actionParameters) {
//   ...
// }
//
// or
//
// foo({_screen, <a>, <b>, <..>}) {
//   ...
// }
//

#JSAction: {
    arguments!: [#ActionParameters]
}

#ActionParameters: {
    "_screen"!: #ScreenInstance
    [string & !="_screen"]: #JSValue
}

#ScreenInstance: {
	instanceId!:  string
	navigatorId!: string
	type!:        string
	// Native contextPath.joined(separator: "."); an empty path becomes "".
	contextPath!: string
}

//
// JS code:
//
// foo(setterParameters) {
//   ...
// }
//
// or
//
// foo({_screen, name, value}}) {
//   ...
// }
//

#JSSetter: {
    arguments!: [#SetterParameters]
}

#SetterParameters: {
    "_screen"!: #ScreenInstance
    name!: string
    value!: #JSValue
}
