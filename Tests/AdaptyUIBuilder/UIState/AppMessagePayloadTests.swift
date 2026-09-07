//
//  AppMessagePayloadTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite(
    "App Message Payload",
    .component("AdaptyUIBuilder"),
    .epic("JavaScript Bridge"),
    .feature("App Message"),
    .risk(.critical),
    .owner("Aleksei Valiano"),
    .layer(.unit)
)
@MainActor
struct AppMessagePayloadTests {
    private final class UnsupportedClass {
        let value = 42
    }

    private struct UnsupportedStruct {
        let value = 42
    }

    private struct ConvertedStruct: JSValueConvertable {
        func toJSValue(in context: JSContext) -> JSValue {
            "converted structure".toJSValue(in: context)
        }
    }

    private final class ConvertedClass: JSValueConvertable {
        var calls = 0

        func toJSValue(in context: JSContext) -> JSValue {
            calls += 1
            return 42.toJSValue(in: context)
        }
    }

    /// JSON data traverses AppMessage and reaches the JS handler with null positions intact.
    @Test("JSON payload survives delivery")
    func jsonPayload() throws {
        let json = #"{"null":null,"bool":true,"false":false,"number":1.5,"integer":42,"string":"Привет 🐈","empty":{},"array":[null,false,0,"",{},[],[null],null]}"#
        let input = try #require(JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])
        let context = try deliver(input)
        let encoded = try #require(context.evaluateScript("JSON.stringify(received.payload)")?.toString())
        let decoded = try #require(JSONSerialization.jsonObject(with: Data(encoded.utf8)) as? NSDictionary)
        #expect(decoded.isEqual(to: input))
        #expect(context.evaluateScript("received.id === 'message-id' && received.name === 'app_msg' && !('screen' in received) && !('element' in received)")?.toBool() == true)
    }

    /// Unsupported classes previously aborted in the raw Objective-C bridge, even when nested.
    @Test("Unsupported values become null recursively")
    func unsupportedValues() throws {
        let context = try deliver([
            "class": UnsupportedClass(),
            "structure": UnsupportedStruct(),
            "object": NSObject(),
            "date": Date(),
            "nested": ["keep": 42, "drop": UnsupportedClass()] as [String: Any],
            "array": [UnsupportedClass(), 1, UnsupportedStruct(), NSNull(), ["drop": UnsupportedClass()]] as [Any],
        ])
        #expect(context.evaluateScript("received.payload.class === null && received.payload.structure === null && received.payload.object === null && received.payload.date === null")?.toBool() == true)
        #expect(context.evaluateScript("received.payload.nested.keep === 42 && received.payload.nested.drop === null")?.toBool() == true)
        #expect(context.evaluateScript("JSON.stringify(received.payload.array) === '[null,1,null,null,{\"drop\":null}]'")?.toBool() == true)
    }

    /// Both Swift structures and classes use their protocol conversion inside mixed collections.
    @Test("Custom converters are called inside collections")
    func customConverters() throws {
        let custom = ConvertedClass()
        let context = try deliver([
            "direct": custom,
            "array": [ConvertedStruct(), ["value": custom]] as [Any],
            "typed": [ConvertedStruct()],
            "typedDictionary": ["value": ConvertedStruct()],
        ])
        #expect(custom.calls == 2)
        #expect(context.evaluateScript("received.payload.direct === 42 && received.payload.array[0] === 'converted structure' && received.payload.array[1].value === 42 && received.payload.typed[0] === 'converted structure' && received.payload.typedDictionary.value === 'converted structure'")?.toBool() == true)
    }

    /// Foundation boxing preserves booleans separately from numbers and supports numeric widths.
    @Test("Foundation and Swift primitives remain values")
    func foundationPrimitives() throws {
        let context = try deliver([
            "string": NSString(string: "text"),
            "bool": NSNumber(value: true),
            "one": NSNumber(value: 1),
            "numbers": [Int8.min, UInt8.max, Int16.min, UInt16.max, Int32.min, UInt32.max, Int64(-64), UInt64(64), Int(-42), UInt(42), Float(1.5), Double(2.5)] as [Any],
        ])
        #expect(context.evaluateScript("received.payload.string === 'text' && received.payload.bool === true && received.payload.one === 1")?.toBool() == true)
        #expect(context.evaluateScript("JSON.stringify(received.payload.numbers) === '[-128,255,-32768,65535,-2147483648,4294967295,-64,64,-42,42,1.5,2.5]'")?.toBool() == true)
    }

    /// Empty optionals remain null while an optional containing an unsupported value also becomes null.
    @Test("Optionals preserve null and unwrap supported values")
    func optionals() throws {
        let context = try deliver([
            "null": Optional<UnsupportedClass>.none as Any,
            "drop": Optional.some(UnsupportedClass()) as Any,
            "custom": Optional.some(ConvertedStruct()) as Any,
            "array": [Optional<Int>.none, Optional<Int>.some(42)],
        ])
        #expect(context.evaluateScript("received.payload.null === null && received.payload.drop === null && received.payload.custom === 'converted structure' && JSON.stringify(received.payload.array) === '[null,42]'")?.toBool() == true)
    }

    /// Literal keys are own properties; none can mutate the payload object's prototype.
    @Test("Special dictionary keys remain data")
    func dictionaryKeys() throws {
        let context = try deliver([
            "__proto__": ["polluted": true],
            "constructor": "data",
            "": NSNull(),
            "a.b": 42,
        ])
        #expect(context.evaluateScript("Object.prototype.hasOwnProperty.call(received.payload, '__proto__') && Object.getPrototypeOf(received.payload) === Object.prototype && received.payload.__proto__.polluted === true && received.payload.polluted === undefined")?.toBool() == true)
        #expect(context.evaluateScript("received.payload.constructor === 'data' && received.payload[''] === null && received.payload['a.b'] === 42")?.toBool() == true)
    }

    /// Cyclic references become null, but shared containers are serialized for each occurrence.
    @Test("Foundation cycles become null without dropping shared collections")
    func cyclesAndSharedCollections() throws {
        let array = NSMutableArray()
        array.add(42)
        array.add(array)
        let dictionary = NSMutableDictionary()
        dictionary["keep"] = true
        dictionary["self"] = dictionary
        defer {
            array.removeAllObjects()
            dictionary.removeAllObjects()
        }
        let shared: NSArray = ["shared"]
        let context = try deliver(["array": array, "object": dictionary, "a": shared, "b": shared])
        #expect(context.evaluateScript("JSON.stringify(received.payload.array) === '[42,null]' && received.payload.object.keep === true && received.payload.object.self === null")?.toBool() == true)
        #expect(context.evaluateScript("JSON.stringify(received.payload.a) === '[\"shared\"]' && JSON.stringify(received.payload.b) === '[\"shared\"]'")?.toBool() == true)
    }

    /// Dictionaries with non-string keys and raw JS values become null as unsupported values.
    @Test("Non-string-keyed dictionaries and raw JSValue become null")
    func unsupportedKeysAndJSValue() throws {
        let foreignContext = try #require(JSContext())
        let raw = try #require(foreignContext.evaluateScript("({value: 42})"))
        let dictionary: NSDictionary = [1: "drop", "keep": 42]
        let context = try deliver(["dictionary": dictionary, "raw": raw])
        #expect(context.evaluateScript("received.payload.dictionary === null && received.payload.raw === null")?.toBool() == true)
    }

    /// Excessive nesting stops at the limit instead of exhausting the native stack.
    @Test("Excessively deep values become null")
    func depthLimit() throws {
        var value: Any = 42
        for _ in 0..<200 { value = [value] }
        let context = try deliver(["deep": value, "keep": true])
        #expect(context.evaluateScript("(() => { let value = received.payload.deep; let depth = 0; while (Array.isArray(value) && value.length) { depth++; value = value[0]; } return depth < 200 && value === null && received.payload.keep === true; })()")?.toBool() == true)
    }

    /// Former error-path characters remain literal keys when unsupported values become null.
    @Test("Quoted and control-character keys survive conversion")
    func escapedKeys() throws {
        let key = "a\"b\\c\n\t\u{0000}"
        let context = try deliver([key: [UnsupportedClass(), "keep"] as [Any]])
        let encoded = try #require(context.evaluateScript("JSON.stringify(received.payload)")?.toString())
        let decoded = try #require(JSONSerialization.jsonObject(with: Data(encoded.utf8)) as? [String: Any])
        #expect(Set(decoded.keys) == [key])
        let values = try #require(decoded[key] as? [Any])
        #expect(values.count == 2)
        #expect(values[0] is NSNull)
        #expect(values[1] as? String == "keep")
    }

    /// The internal bridge preserves special JS Number values rather than JSON-stringifying them.
    @Test("Non-finite numbers and negative zero reach JavaScript")
    func nonFiniteNumbers() throws {
        let context = try deliver([
            "nan": Double.nan,
            "positive": Double.infinity,
            "negative": -Double.infinity,
            "floatNaN": Float.nan,
            "negativeZero": -Double.zero,
        ])
        #expect(context.evaluateScript("Number.isNaN(received.payload.nan) && Number.isNaN(received.payload.floatNaN) && received.payload.positive === Infinity && received.payload.negative === -Infinity && Object.is(received.payload.negativeZero, -0)")?.toBool() == true)
    }

    /// AppMessage now uses the existing Number conversion instead of the removed precision error.
    @Test("Large integers follow JavaScript Number precision")
    func integerPrecision() throws {
        let context = try deliver([
            "exact": Int64(9_007_199_254_740_992),
            "rounded": Int64(9_007_199_254_740_993),
            "minimum": Int64.min,
            "maximum": UInt64.max,
        ])
        #expect(context.evaluateScript("received.payload.exact === 9007199254740992 && received.payload.rounded === 9007199254740992 && typeof received.payload.rounded === 'number'")?.toBool() == true)
        let payload = try #require(context.evaluateScript("received.payload"))
        #expect(payload.forProperty("minimum")?.toDouble() == Double(Int64.min))
        #expect(payload.forProperty("maximum")?.toDouble() == Double(UInt64.max))
    }

    /// 128-bit integers have no JSValueConvertable conformance or NSNumber bridge.
    @Test("Unsupported 128-bit integers become null")
    func wideIntegers() throws {
        if #available(iOS 18.0, macOS 15.0, *) {
            let number = UInt128(1) << 100
            let context = try deliver([
                "values": [Int128(42), number, number + 1] as [Any],
            ])
            #expect(context.evaluateScript("JSON.stringify(received.payload.values) === '[null,null,null]'")?.toBool() == true)
        }
    }

    /// Unlike unsupported Foundation objects, NSDecimalNumber follows NSNumber.doubleValue.
    @Test("Decimal numbers use the Foundation number bridge")
    func decimalNumbers() throws {
        let number = NSDecimalNumber(string: "0.1")
        let context = try deliver(["value": number])
        let value = try #require(context.evaluateScript("received.payload.value"))
        #expect(value.isNumber)
        #expect(value.toDouble() == number.doubleValue)
    }

    /// Each delivery builds independent JS arrays from shared mutable Foundation containers.
    @Test("Delivered collections are snapshots")
    func collectionSnapshot() throws {
        let shared = NSMutableArray(array: [42])
        let context = try deliver(["a": shared, "b": shared])
        shared.removeAllObjects()
        #expect(context.evaluateScript("JSON.stringify(received.payload.a) === '[42]' && JSON.stringify(received.payload.b) === '[42]' && received.payload.a !== received.payload.b")?.toBool() == true)
    }

    private func deliver(_ payload: [String: Any]) throws -> JSContext {
        let context = try #require(JSContext())
        context.evaluateScript("function handleSDKEvent(event) { globalThis.received = event; return 123; }")
        let message = try VS.AppMessage(id: "message-id", payload: payload)
        let handler = try #require(context.objectForKeyedSubscript("handleSDKEvent"))
        let event = VS.SDKEvent.appMessage(message: message).toJSValue(in: context)
        let result = try #require(handler.call(withArguments: [event]))
        #expect(result.toInt32() == 123)
        #expect(context.exception == nil)
        return context
    }
}
