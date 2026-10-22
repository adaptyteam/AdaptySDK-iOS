#if canImport(UIKit)
@testable import AdaptyUIBuilder
import Testing

@Suite("UIBuilder product lookup")
struct AdaptyUIProductsViewModelTests {
    @Test("Repeated flow product IDs keep the first synthetic resolver")
    func repeatedFlowProductIdsKeepFirstResolver() {
        let products: [any ProductResolver] = [
            SyntheticProductResolver(flowId: "shared", marker: "first"),
            SyntheticProductResolver(flowId: "shared", marker: "second"),
            SyntheticProductResolver(flowId: "other", marker: "other"),
        ]

        let lookup = makeProductLookupByFlowId(products)

        #expect(lookup.count == 2)
        #expect((lookup["shared"] as? SyntheticProductResolver)?.marker == "first")
        #expect(lookup["other"]?.flowId == "other")
    }
}

private struct SyntheticProductResolver: ProductResolver {
    let flowId: String
    let marker: String

    var paymentMode: PaymentModeValue { nil }

    func value(byTag tag: TextProductTag) -> TextTagValue? {
        nil
    }
}
#endif
