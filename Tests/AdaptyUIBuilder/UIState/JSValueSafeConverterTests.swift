//
//  JSValueSafeConverterTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite(
    "JSValue Safe Converter",
    .component("AdaptyUIBuilder"),
    .epic("JavaScript Bridge"),
    .feature("Safe Conversion"),
    .risk(.critical),
    .owner("Aleksei Valiano"),
    .layer(.unit)
)
@MainActor
struct JSValueSafeConverterTests {
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

    /// JSON data preserves its values and null positions through conversion.
    @Test("JSON values survive conversion")
    func jsonPayload() throws {
        let json = #"{"null":null,"bool":true,"false":false,"number":1.5,"integer":42,"string":"Привет 🐈","empty":{},"array":[null,false,0,"",{},[],[null],null]}"#
        let input = try #require(JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])
        let context = try convert(input)
        let encoded = try #require(context.evaluateScript("JSON.stringify(converted)")?.toString())
        let decoded = try #require(JSONSerialization.jsonObject(with: Data(encoded.utf8)) as? NSDictionary)
        #expect(decoded.isEqual(to: input))
    }

    /// Unsupported classes previously aborted in the raw Objective-C bridge, even when nested.
    @Test("Unsupported values become null recursively")
    func unsupportedValues() throws {
        let context = try convert([
            "class": UnsupportedClass(),
            "structure": UnsupportedStruct(),
            "object": NSObject(),
            "date": Date(),
            "nested": ["keep": 42, "drop": UnsupportedClass()] as [String: Any],
            "array": [UnsupportedClass(), 1, UnsupportedStruct(), NSNull(), ["drop": UnsupportedClass()]] as [Any],
        ])
        #expect(context.evaluateScript("converted.class === null && converted.structure === null && converted.object === null && converted.date === null")?.toBool() == true)
        #expect(context.evaluateScript("converted.nested.keep === 42 && converted.nested.drop === null")?.toBool() == true)
        #expect(context.evaluateScript("JSON.stringify(converted.array) === '[null,1,null,null,{\"drop\":null}]'")?.toBool() == true)
    }

    /// Both Swift structures and classes use their protocol conversion inside mixed collections.
    @Test("Custom converters are called inside collections")
    func customConverters() throws {
        let custom = ConvertedClass()
        let context = try convert([
            "direct": custom,
            "array": [ConvertedStruct(), ["value": custom]] as [Any],
            "typed": [ConvertedStruct()],
            "typedDictionary": ["value": ConvertedStruct()],
        ])
        #expect(custom.calls == 2)
        #expect(context.evaluateScript("converted.direct === 42 && converted.array[0] === 'converted structure' && converted.array[1].value === 42 && converted.typed[0] === 'converted structure' && converted.typedDictionary.value === 'converted structure'")?.toBool() == true)
    }

    /// Foundation boxing preserves booleans separately from numbers and supports numeric widths.
    @Test("Foundation and Swift primitives remain values")
    func foundationPrimitives() throws {
        let context = try convert([
            "string": NSString(string: "text"),
            "bool": NSNumber(value: true),
            "one": NSNumber(value: 1),
            "numbers": [Int8.min, UInt8.max, Int16.min, UInt16.max, Int32.min, UInt32.max, Int64(-64), UInt64(64), Int(-42), UInt(42), Float(1.5), Double(2.5)] as [Any],
        ])
        #expect(context.evaluateScript("converted.string === 'text' && converted.bool === true && converted.one === 1")?.toBool() == true)
        #expect(context.evaluateScript("JSON.stringify(converted.numbers) === '[-128,255,-32768,65535,-2147483648,4294967295,-64,64,-42,42,1.5,2.5]'")?.toBool() == true)
    }

    @Test("Foundation values convert directly through the protocol")
    func foundationProtocolConformance() throws {
        let context = try #require(JSContext())
        let string: Any = NSString(string: "Привет 🐈")
        let convertibleString = try #require(string as? any JSValueConvertable)
        #expect(convertibleString.toJSValue(in: context).toString() == "Привет 🐈")
        for number in [NSNumber(value: true), NSNumber(value: false)] {
            let convertible = try #require((number as Any) as? any JSValueConvertable)
            let value = convertible.toJSValue(in: context)
            #expect(value.isBoolean)
            #expect(value.toBool() == number.boolValue)
        }
        for number in [NSNumber(value: 1), NSNumber(value: 0), NSNumber(value: 1.5), NSDecimalNumber(string: "0.1")] {
            let convertible = try #require((number as Any) as? any JSValueConvertable)
            let value = convertible.toJSValue(in: context)
            #expect(value.isNumber)
            #expect(value.toDouble() == number.doubleValue)
        }
        #expect(context.exception == nil)
    }

    /// Empty optionals remain null while an optional containing an unsupported value also becomes null.
    @Test("Optionals preserve null and unwrap supported values")
    func optionals() throws {
        let context = try convert([
            "null": Optional<UnsupportedClass>.none as Any,
            "drop": Optional.some(UnsupportedClass()) as Any,
            "custom": Optional.some(ConvertedStruct()) as Any,
            "array": [Optional<Int>.none, Optional<Int>.some(42)],
        ])
        #expect(context.evaluateScript("converted.null === null && converted.drop === null && converted.custom === 'converted structure' && JSON.stringify(converted.array) === '[null,42]'")?.toBool() == true)
    }

    /// Literal keys are own properties; none can mutate the converted object's prototype.
    @Test("Special dictionary keys remain data")
    func dictionaryKeys() throws {
        let context = try convert([
            "__proto__": ["polluted": true],
            "constructor": "data",
            "": NSNull(),
            "a.b": 42,
        ])
        #expect(context.evaluateScript("Object.prototype.hasOwnProperty.call(converted, '__proto__') && Object.getPrototypeOf(converted) === Object.prototype && converted.__proto__.polluted === true && converted.polluted === undefined")?.toBool() == true)
        #expect(context.evaluateScript("converted.constructor === 'data' && converted[''] === null && converted['a.b'] === 42")?.toBool() == true)
    }

    @Test("Converted properties retain independent values and mutable data descriptors")
    func propertyDescriptors() throws {
        let context = try convert([
            "first": 1,
            "second": "two",
            "nested": ["value": true],
            "__proto__": NSNull(),
        ] as [String: Any])
        #expect(context.evaluateScript("converted.first === 1 && converted.second === 'two' && converted.nested.value === true && converted.__proto__ === null")?.toBool() == true)
        #expect(context.evaluateScript("[converted, converted.nested].every(object => Object.keys(object).every(key => { const d = Object.getOwnPropertyDescriptor(object, key); return d.writable && d.enumerable && d.configurable && !('get' in d) && !('set' in d); }))")?.toBool() == true)
        #expect(context.evaluateScript("converted.first = 42; delete converted.second; converted.first === 42 && !Object.prototype.hasOwnProperty.call(converted, 'second')")?.toBool() == true)
        #expect(context.exception == nil)
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
        let context = try convert(["array": array, "object": dictionary, "a": shared, "b": shared])
        #expect(context.evaluateScript("JSON.stringify(converted.array) === '[42,null]' && converted.object.keep === true && converted.object.self === null")?.toBool() == true)
        #expect(context.evaluateScript("JSON.stringify(converted.a) === '[\"shared\"]' && JSON.stringify(converted.b) === '[\"shared\"]'")?.toBool() == true)
    }

    /// Dictionaries with non-string keys and raw JS values become null as unsupported values.
    @Test("Non-string-keyed dictionaries and raw JSValue become null")
    func unsupportedKeysAndJSValue() throws {
        let foreignContext = try #require(JSContext())
        let raw = try #require(foreignContext.evaluateScript("({value: 42})"))
        let dictionary: NSDictionary = [1: "drop", "keep": 42]
        let context = try convert(["dictionary": dictionary, "raw": raw])
        #expect(context.evaluateScript("converted.dictionary === null && converted.raw === null")?.toBool() == true)
    }

    /// Excessive nesting stops at the limit instead of exhausting the native stack.
    @Test("Excessively deep values become null")
    func depthLimit() throws {
        var value: Any = 42
        for _ in 0..<200 { value = [value] }
        let context = try convert(["deep": value, "keep": true])
        #expect(context.evaluateScript("(() => { let value = converted.deep; let depth = 0; while (Array.isArray(value) && value.length) { depth++; value = value[0]; } return depth === 128 && value === null && converted.keep === true; })()")?.toBool() == true)
    }

    /// Former error-path characters remain literal keys when unsupported values become null.
    @Test("Quoted and control-character keys survive conversion")
    func escapedKeys() throws {
        let key = "a\"b\\c\n\t\u{0000}"
        let context = try convert([key: [UnsupportedClass(), "keep"] as [Any]])
        let encoded = try #require(context.evaluateScript("JSON.stringify(converted)")?.toString())
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
        let context = try convert([
            "nan": Double.nan,
            "positive": Double.infinity,
            "negative": -Double.infinity,
            "floatNaN": Float.nan,
            "negativeZero": -Double.zero,
        ])
        #expect(context.evaluateScript("Number.isNaN(converted.nan) && Number.isNaN(converted.floatNaN) && converted.positive === Infinity && converted.negative === -Infinity && Object.is(converted.negativeZero, -0)")?.toBool() == true)
    }

    /// Large integers use the existing JavaScript Number conversion.
    @Test("Large integers follow JavaScript Number precision")
    func integerPrecision() throws {
        let context = try convert([
            "exact": Int64(9_007_199_254_740_992),
            "rounded": Int64(9_007_199_254_740_993),
            "minimum": Int64.min,
            "maximum": UInt64.max,
        ])
        #expect(context.evaluateScript("converted.exact === 9007199254740992 && converted.rounded === 9007199254740992 && typeof converted.rounded === 'number'")?.toBool() == true)
        let converted = try #require(context.evaluateScript("converted"))
        #expect(converted.forProperty("minimum")?.toDouble() == Double(Int64.min))
        #expect(converted.forProperty("maximum")?.toDouble() == Double(UInt64.max))
    }

    /// 128-bit integers have no JSValueConvertable conformance or NSNumber bridge.
    @Test("Unsupported 128-bit integers become null")
    func wideIntegers() throws {
        if #available(iOS 18.0, macOS 15.0, *) {
            let number = UInt128(1) << 100
            let context = try convert([
                "values": [Int128(42), number, number + 1] as [Any],
            ])
            #expect(context.evaluateScript("JSON.stringify(converted.values) === '[null,null,null]'")?.toBool() == true)
        }
    }

    /// Unlike unsupported Foundation objects, NSDecimalNumber follows NSNumber.doubleValue.
    @Test("Decimal numbers use the Foundation number bridge")
    func decimalNumbers() throws {
        let number = NSDecimalNumber(string: "0.1")
        let context = try convert(["value": number])
        let value = try #require(context.evaluateScript("converted.value"))
        #expect(value.isNumber)
        #expect(value.toDouble() == number.doubleValue)
    }

    /// Conversion builds independent JS arrays from shared mutable Foundation containers.
    @Test("Converted collections are snapshots")
    func collectionSnapshot() throws {
        let shared = NSMutableArray(array: [42])
        let context = try convert(["a": shared, "b": shared])
        shared.removeAllObjects()
        #expect(context.evaluateScript("JSON.stringify(converted.a) === '[42]' && JSON.stringify(converted.b) === '[42]' && converted.a !== converted.b")?.toBool() == true)
    }

    @Test("Root values support primitives, arrays and custom converters")
    func rootValues() throws {
        let context = try #require(JSContext())
        #expect(JSValue.safeConvert(from: true, context: context).toBool())
        #expect(JSValue.safeConvert(from: 42, context: context).toInt32() == 42)
        #expect(JSValue.safeConvert(from: Float(1.5), context: context).toDouble() == 1.5)
        #expect(JSValue.safeConvert(from: Int64.min, context: context).toDouble() == Double(Int64.min))
        #expect(JSValue.safeConvert(from: UInt64.max, context: context).toDouble() == Double(UInt64.max))
        #expect(JSValue.safeConvert(from: "text", context: context).toString() == "text")
        #expect(JSValue.safeConvert(from: NSNull(), context: context).isNull)
        #expect(JSValue.safeConvert(from: UnsupportedClass(), context: context).isNull)
        #expect(JSValue.safeConvert(from: ConvertedStruct(), context: context).toString() == "converted structure")
        let custom = ConvertedClass()
        #expect(JSValue.safeConvert(from: custom, context: context).toInt32() == 42)
        #expect(custom.calls == 1)
        let arrayContext = try convert([42, UnsupportedClass(), NSNull()] as [Any])
        #expect(arrayContext.evaluateScript("JSON.stringify(converted) === '[42,null,null]'")?.toBool() == true)
    }

    @Test("Optional root values support nil and wrapped values")
    func optionalRootValues() throws {
        let context = try #require(JSContext())
        let missing: Any? = nil
        let present: Any? = 42
        let unsupported: Any? = UnsupportedClass()
        #expect(JSValue.safeConvert(from: missing, context: context).isNull)
        #expect(JSValue.safeConvert(from: present, context: context).toInt32() == 42)
        #expect(JSValue.safeConvert(from: unsupported, context: context).isNull)
        #expect(JSValue.safeConvert(from: Optional<Int>.none as Any, context: context).isNull)
        #expect(JSValue.safeConvert(from: Optional.some(42) as Any, context: context).toInt32() == 42)
    }

    @Test("Configured depth includes the root at zero", arguments: [-1, 0, 1, 2])
    func configuredDepth(maxDepth: Int) throws {
        let context = try #require(JSContext())
        let array = JSValue.safeConvert(from: [[42]], context: context, maxDepth: maxDepth)
        let optionalObject: Any? = ["nested": ["value": 42]]
        let object = JSValue.safeConvert(from: optionalObject, context: context, maxDepth: maxDepth)
        context.setObject(array, forKeyedSubscript: "array" as NSString)
        context.setObject(object, forKeyedSubscript: "object" as NSString)
        let expectedArrays = ["null", "[null]", "[[null]]", "[[42]]"]
        let expectedObjects = ["null", #"{"nested":null}"#, #"{"nested":{"value":null}}"#, #"{"nested":{"value":42}}"#]
        #expect(context.evaluateScript("JSON.stringify(array)")?.toString() == expectedArrays[maxDepth + 1])
        #expect(context.evaluateScript("JSON.stringify(object)")?.toString() == expectedObjects[maxDepth + 1])
        #expect(context.exception == nil)
    }

    private func convert(_ value: Any) throws -> JSContext {
        let context = try #require(JSContext())
        let converted = JSValue.safeConvert(from: value, context: context)
        context.setObject(converted, forKeyedSubscript: "converted" as NSString)
        #expect(context.exception == nil)
        return context
    }
}
