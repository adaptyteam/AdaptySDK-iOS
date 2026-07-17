//
//  AdaptyUIInterfaceOrientationReader.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI
import UIKit

/// Publishes the interface orientation of the window the paywall is attached to,
/// and keeps it up to date across rotations.
///
/// It exists because interface orientation is not observable SwiftUI state:
/// reading it once leaves render-time `orientation` conditions in `switch` /
/// `flex` / `flex_stack` stale after a rotation. The value is refreshed from
/// `viewWillTransition(to:with:)`, in the transition's completion, where the
/// interface orientation is already settled — this fires whether or not the
/// paywall's own frame changes (so it also works for embedded / fixed-size
/// flows), and needs no global device-orientation notifications. Reading from
/// the view's own `UIWindowScene` avoids picking an unrelated scene in
/// multi-window setups.
///
/// On platforms without a rotatable interface (Mac Catalyst, tvOS, visionOS)
/// there is nothing to observe, so it reports a fixed `.landscape` once.
struct AdaptyUIInterfaceOrientationReader: UIViewControllerRepresentable {
    @Binding var orientation: VC.Orientation

    func makeUIViewController(context _: Context) -> OrientationReportingController {
        let controller = OrientationReportingController()
        controller.onChange = { orientation = $0 }
        return controller
    }

    func updateUIViewController(_: OrientationReportingController, context _: Context) {}
}

final class OrientationReportingController: UIViewController {
    var onChange: ((VC.Orientation) -> Void)?
    private var reported: VC.Orientation?

    private func report(_ orientation: VC.Orientation) {
        guard reported != orientation else { return }
        reported = orientation
        onChange?(orientation)
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(VC.Orientation.of(view.window?.windowScene))
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            self.report(VC.Orientation.of(self.view.window?.windowScene))
        }
    }
    #else
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(.landscape)
    }
    #endif
}

#endif
