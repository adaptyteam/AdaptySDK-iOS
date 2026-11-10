@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite("Optional fields in SDK JavaScript objects", .tags(.codable))
@MainActor
struct JSOptionalFieldsTests {
    @Test("Product constants omit nil and preserve empty strings, zero and false", arguments: [false, true])
    func productConstants(populated: Bool) throws {
        let context = try #require(JSContext())
        let optionalString: String? = populated ? "" : nil
        let price = VC.FlowConstants.PriceConstants(amount: 0, currencyCode: "USD", currencySymbol: optionalString, localizedString: "")
        let period = VC.FlowConstants.SubscriptionPeriodConstants(unit: "month", numberOfUnits: 1)
        let offer = VC.FlowConstants.SubscriptionOfferConstants(
            id: optionalString,
            type: "introductory",
            price: populated ? price : nil,
            paymentMode: "free_trial",
            period: period,
            numberOfPeriods: 1,
            localizedPeriod: optionalString,
            localizedNumberOfPeriods: optionalString
        )
        let subscription = VC.FlowConstants.ProductSubscriptionConstants(
            groupIdentifier: "group",
            period: period,
            localizedPeriod: optionalString,
            pricingTerms: .init(
                billingPlanId: "up_front",
                billingPrice: price,
                billingPeriod: period,
                commitmentInfo: .init(price: price, period: period)
            ),
            offer: populated ? offer : nil
        )
        let product = VC.FlowConstants.ProductConstants(
            flowProductId: "product",
            adaptyProductId: "id",
            adaptyAccessLevelId: "premium",
            adaptyProductType: "monthly",
            paywallVariationId: "variation",
            paywallName: "name",
            localizedDescription: "",
            localizedTitle: "",
            isFamilyShareable: false,
            regionCode: optionalString,
            price: price,
            subscription: populated ? subscription : nil
        )

        let jsPrice = price.value.toJSValue(in: context)
        let jsOffer = offer.value.toJSValue(in: context)
        let jsPhase = try #require(jsOffer.forProperty("phases")?.atIndex(0))
        let jsSubscription = subscription.value.toJSValue(in: context)
        let jsProduct = product.value.toJSValue(in: context)

        for (object, keys) in [
            (jsPrice, ["currencySymbol"]),
            (jsOffer, ["id"]),
            (jsPhase, ["localizedPeriod", "localizedNumberOfPeriods"]),
            (jsSubscription, ["localizedPeriod"]),
            (jsProduct, ["regionCode"]),
        ] {
            for key in keys {
                #expect(object.hasProperty(key) == populated)
                if populated {
                    let value = try #require(object.forProperty(key))
                    #expect(value.isString)
                    #expect(value.toString() == "")
                }
            }
        }
        #expect(jsPhase.hasProperty("price") == populated)
        #expect(jsSubscription.hasProperty("offer") == populated)
        #expect(jsProduct.hasProperty("subscription") == populated)
        #expect(jsPrice.forProperty("amount")?.isNumber == true)
        #expect(jsPrice.forProperty("amount")?.toDouble() == 0)
        #expect(jsPrice.forProperty("localizedString")?.toString() == "")
        #expect(jsProduct.forProperty("isFamilyShareable")?.isBoolean == true)
        #expect(jsProduct.forProperty("isFamilyShareable")?.toBool() == false)
        #expect(jsProduct.forProperty("localizedTitle")?.toString() == "")
        #expect(jsProduct.hasProperty("price"))
        #expect(jsSubscription.hasProperty("period"))
        #expect(jsSubscription.hasProperty("pricingTerms"))
        #expect(context.exception == nil)
    }

    @Test("Callback responses omit absent strings and preserve supplied strings", arguments: [nil, "", "value"] as [String?])
    func callbackResponses(value: String?) throws {
        let context = try #require(JSContext())
        let alert = VS.ShowAlertDialogResponse(actionId: value).toJSValue(in: context)
        let permission = VS.ShowRequestPermissionResponse(
            request: .init(permission: value, customArgs: value.map { ["key": $0] }),
            result: false,
            detailResult: value
        ).toJSValue(in: context)

        for (object, key) in [(alert, "actionId"), (permission, "permission"), (permission, "detailResult")] {
            #expect(object.hasProperty(key) == (value != nil))
            if let value {
                let field = try #require(object.forProperty(key))
                #expect(field.isString)
                #expect(field.toString() == value)
            }
        }
        #expect(permission.hasProperty("customArgs") == (value != nil))
        #expect(permission.forProperty("result")?.isBoolean == true)
        #expect(permission.forProperty("result")?.toBool() == false)
        #expect(context.exception == nil)
    }
}
