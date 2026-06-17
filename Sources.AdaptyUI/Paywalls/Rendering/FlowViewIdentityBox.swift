//
//  FlowViewIdentityBox.swift
//  AdaptyUI
//
//  Created by Alexey Goncharov on 6/16/26.
//

#if canImport(UIKit)

/// Reference holder for the active flow view's identity.
///
/// The view instance id is known only once `AdaptyFlowUIView.init` runs (a
/// generated UUID for presented views, the host-provided id for platform
/// views). This box is created up front, shared with the cross-platform plugin
/// layer, and late-bound at view init — letting the plugin's per-view
/// `AdaptyObserverModeResolver` / `AdaptyUISystemRequestsHandler` stamp their
/// host events with the originating view without threading it through the
/// public protocols. Internal plumbing — not part of the public SDK surface.
@MainActor
package final class FlowViewIdentityBox {
    package var value: AdaptyUI.FlowView?
    package init() {}
}

#endif
