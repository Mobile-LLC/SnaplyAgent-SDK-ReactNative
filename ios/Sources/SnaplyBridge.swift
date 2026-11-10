//
//  SnaplyBridge.swift
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

import Foundation
import SnaplyAgent
import UIKit

/// The Swift SDK, as the Objective-C++ module can call it.
@objc(SnaplyBridge)
public final class SnaplyBridge: NSObject {
    /// Sends one SDK event to JavaScript. Set by the module.
    @objc public static var emit: (([String: Any]) -> Void)?
    /// Passes a tap into React Native's own touch system; false when nothing there takes touches. Set by the module.
    @objc public static var tapRelay: ((UIView, CGPoint) -> Bool)?

    private static let host = ReactSurfaceHost()

    @objc public static func configure(
        key: String,
        host: String?,
        userId: String?,
        userName: String?,
        collectVendorId: Bool,
        language: String,
        completion: @escaping (String?, String?, Int) -> Void
    ) {
        onMain {
            var environment = SnaplyEnvironment.live
            if let host {
                guard let url = URL(string: host) else { return completion("insecure_environment", "environment is not a URL.", 0) }
                environment = .custom(url)
            }
            Snaply.on(callbacks)
            self.host.attach()
            Snaply.configure(
                key: key,
                environment: environment,
                user: userId.map { SnaplyUser(id: $0, name: userName) },
                collectVendorId: collectVendorId,
                language: language
            ) { error in
                guard let error else { return completion(nil, nil, 0) }
                let snaply = error as? SnaplyError
                completion(snaply?.code ?? "error", snaply?.message ?? error.localizedDescription, snaply?.status ?? 0)
            }
        }
    }

    @objc public static func identify(id: String, name: String?, phone: String?, identitySignature: String?) {
        onMain { Snaply.identify(id: id, name: name, phone: phone, identitySignature: identitySignature) }
    }

    @objc public static func reset() {
        onMain { Snaply.reset() }
    }

    @objc public static func supportCode(_ completion: @escaping (String?) -> Void) {
        onMain { completion(Snaply.supportCode()) }
    }

    @objc public static func showSupportCode() {
        onMain { Snaply.showSupportCode() }
    }

    @objc public static func stop() {
        onMain { Snaply.stop() }
    }

    private static func onMain(_ work: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async { MainActor.assumeIsolated { work() } }
    }

    private static var callbacks: SnaplyCallbacks {
        SnaplyCallbacks(
            onRequestShown: { send("requestShown") },
            onAllowed: { capture in send("allowed", ["captureId": capture.captureId, "imageUrl": capture.imageUrl]) },
            onDenied: { send("denied") },
            onExpired: { send("expired") },
            onError: { error in
                let snaply = error as? SnaplyError
                send("error", ["code": snaply?.code ?? "error", "message": snaply?.message ?? error.localizedDescription, "status": snaply?.status ?? 0])
            },
            onRemoteControl: { active in send("remoteControl", ["active": active]) },
            onLiveEnded: { session in send("liveEnded", ["sessionId": session.sessionId]) }
        )
    }

    private static func send(_ name: String, _ fields: [String: Any] = [:]) {
        emit?(fields.merging(["name": name]) { _, new in new })
    }
}

/// React Native answers a touch, not an accessibility activation: a tap the SDK could not deliver its own way
/// is offered here and passed on as a touch. The SDK keeps capturing and hiding the screen itself — it is
/// native views.
private final class ReactSurfaceHost: SnaplyHostedView {
    private weak var surface: UIView?

    var providesSnapshot: Bool { false }
    var controlMode: SnaplyHostedControlMode { .fallback }

    @MainActor
    func attach() {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController?.view
        guard root !== surface else { return }
        if let surface { Snaply.registerHostedView(surface, host: nil) }
        surface = root
        if let root { Snaply.registerHostedView(root, host: self) }
    }

    @MainActor
    func snapshot(_ request: SnaplyHostedSnapshotRequest, completion: @escaping (SnaplyHostedSnapshot?) -> Void) {
        completion(nil)
    }

    @MainActor
    func control(_ input: SnaplyHostedInput) -> Bool {
        guard input.action == .tap, let surface else { return false }
        return SnaplyBridge.tapRelay?(surface, input.point) ?? false
    }
}
