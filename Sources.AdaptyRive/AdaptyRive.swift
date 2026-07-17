//
//  AdaptyRive.swift
//  AdaptyRive
//
//  Proof of concept: default Rive renderer addon. Depends on the rive-ios SPM
//  package; this is the only target that links RiveRuntime.
//
//  Uses the new rive-ios runtime (Worker → File → Rive), whose loading is
//  `async throws` — a bad animation_id / artboard / state machine is caught and
//  degrades to a visible error (DEBUG) or empty space (release) instead of the
//  `fatalError` the legacy `RiveViewModel` path would raise.
//

#if canImport(UIKit)

import AdaptyUIBuilder
import Foundation
import RiveRuntime
import SwiftUI

public struct AdaptyRive: AdaptyUIRiveAddon {
    public init() {}

    @MainActor
    public func makeView(context: AdaptyUIRiveContext) -> AnyView {
        AnyView(RiveElementView(context: context))
    }
}

/// Owns the async load so failures degrade instead of crashing. `RiveRuntime` ships
/// its own `Color` type, so SwiftUI's is spelled out where they'd collide.
@MainActor
private struct RiveElementView: View {
    let context: AdaptyUIRiveContext

    @State private var phase: Phase = .loading

    private enum Phase {
        case loading
        case loaded(Rive)
        case failed(String)
    }

    var body: some View {
        content
            .task(id: reloadKey) { await load() }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loading:
            SwiftUI.Color.clear
        case let .loaded(rive):
            RiveUIViewRepresentable(rive: rive)
                .paused(!context.autoplay)
        case let .failed(message):
            #if DEBUG
            Text(message)
                .font(.caption2)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding(4)
            #else
            SwiftUI.Color.clear
            #endif
        }
    }

    /// Reload when any input that changes the loaded object changes.
    private var reloadKey: String {
        "\(context.animationId)|\(context.artboard ?? "")|\(context.stateMachine ?? "")|\(context.fit.rawValue)"
    }

    private func load() async {
        do {
            // `Source.local` takes a bundle-resource name without the `.riv` extension.
            let name = context.animationId.hasSuffix(".riv")
                ? String(context.animationId.dropLast(".riv".count))
                : context.animationId

            let worker = try await Worker()
            let file = try await File(source: .local(name, Bundle.main), worker: worker)
            // `nil` name → default artboard / default state machine. The new runtime
            // plays through a state machine; it does not play bare linear animations.
            let artboard = try await file.createArtboard(context.artboard)
            let stateMachine = try await artboard.createStateMachine(context.stateMachine)
            let rive = try await Rive(
                file: file,
                artboard: artboard,
                stateMachine: stateMachine,
                fit: context.fit.riveFit
            )
            // Data binding: inject values, then fire triggers, into the auto-bound
            // default view-model instance. No-ops if the file has no view model.
            if let viewModel = rive.viewModelInstance {
                for (path, value) in context.values {
                    switch value {
                    case let .number(number):
                        viewModel.setValue(of: NumberProperty(path: path), to: Float(number))
                    case let .boolean(bool):
                        viewModel.setValue(of: BoolProperty(path: path), to: bool)
                    case let .string(string):
                        viewModel.setValue(of: StringProperty(path: path), to: string)
                    }
                }
                for path in context.triggers {
                    viewModel.fire(trigger: TriggerProperty(path: path))
                }
            }
            phase = .loaded(rive)
        } catch {
            phase = .failed("Rive load failed: \(context.animationId)\n\(error.localizedDescription)")
        }
    }
}

private extension AdaptyUIRiveFit {
    /// Neutral SDK vocabulary → Rive's own `Fit`. Kept in this target so the core
    /// never sees a vendor type. `stretch` maps to `.fill` (Rive's non-aspect stretch).
    var riveFit: Fit {
        switch self {
        case .fit: .contain(alignment: .center)
        case .fill: .cover(alignment: .center)
        case .stretch: .fill(alignment: .center)
        }
    }
}

#endif
