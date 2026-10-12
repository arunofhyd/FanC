//
//  AboutWindow.swift
//  FanC
//
//  Signature About Window adhering to Arun Thomas's macOS App Blueprint.
//

import AppKit
import SwiftUI
import FanCCore

final class AboutWindowController: NSWindowController {
    static let shared = AboutWindowController()

    private convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 490),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.isReleasedWhenClosed = false

        let visualEffect = NSVisualEffectView()
        visualEffect.material = .popover
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active

        let hostingView = NSHostingView(rootView: AboutContentView())
        visualEffect.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor)
        ])

        window.contentView = visualEffect
        self.init(window: window)
    }

    func show() {
        guard let window = self.window else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct AboutContentView: View {
    @State private var checkingUpdate = false
    @State private var updateStatus: String? = nil

    private var appVersion: String {
        if let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, !v.isEmpty {
            return v
        }
        return FanCVersion.current
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header: App Icon + Title
            VStack(spacing: 8) {
                if let icon = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 64, height: 64)
                        Image(systemName: "fan.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                }

                Text("FanC")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                Text("Version \(appVersion)")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.secondary)

                Text("Intelligent, Proactive Fan Control & Thermal Engine for Apple Silicon")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 28)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 20)

            // Features List
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    symbol: "fan.fill",
                    tintColor: .teal,
                    title: "Smart Adaptive Fan Curves",
                    description: "Five proportional curve profiles tailored for M1 through M6 Apple Silicon architectures."
                )

                FeatureRow(
                    symbol: "flame.fill",
                    tintColor: .orange,
                    title: "Proactive Spike Detection",
                    description: "Anticipates thermal climbs and ramps fans before CPU/GPU throttle thresholds."
                )

                FeatureRow(
                    symbol: "shield.checkerboard",
                    tintColor: .red,
                    title: "Daemon Safety Override & Crash Watchdog",
                    description: "Guaranteed 95°C thermal floor and auto-reversion to Apple defaults if interrupted."
                )

                FeatureRow(
                    symbol: "terminal.fill",
                    tintColor: .purple,
                    title: "Scriptable 'fanc' CLI",
                    description: "Complete command-line interface for daemon management, monitoring, and live telemetry."
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()
                .padding(.horizontal, 20)

            // Author Note & Credits
            VStack(spacing: 4) {
                Text("Built by Arun Thomas")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Text("Proudly based on the pioneering engineering of")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                    Button {
                        if let url = URL(string: "https://github.com/ProducerGuy/ThermalForge") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Text("ThermalForge")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.accentColor)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    Text("by ProducerGuy")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 14)

            // Pill Action Buttons
            HStack(spacing: 12) {
                // Contact Button
                Button {
                    let mailURL = URL(string: "mailto:arunthomas04042001@gmail.com?subject=FanC%20Feedback")!
                    NSWorkspace.shared.open(mailURL)
                } label: {
                    Text("Contact")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 100, height: 32)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)

                // GitHub Button
                Button {
                    let ghURL = URL(string: "https://github.com/arunofhyd/FanC")!
                    NSWorkspace.shared.open(ghURL)
                } label: {
                    Text("GitHub")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 32)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                // Check for Updates Button
                Button {
                    checkForUpdates()
                } label: {
                    HStack(spacing: 4) {
                        if checkingUpdate {
                            ProgressView()
                                .scaleEffect(0.6)
                                .frame(width: 12, height: 12)
                        }
                        Text(checkingUpdate ? "Checking..." : (updateStatus ?? "Updates"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(width: 100, height: 32)
                    .background(Color.secondary.opacity(0.18))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(checkingUpdate)
            }
            .padding(.bottom, 24)
        }
        .frame(width: 460)
    }

    private func checkForUpdates() {
        checkingUpdate = true
        updateStatus = nil

        Task {
            let result = await UpdateChecker.check(current: appVersion)
            await MainActor.run {
                checkingUpdate = false
                switch result {
                case .upToDate:
                    updateStatus = "Latest ✓"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.updateStatus = nil
                    }
                case .update(let update):
                    updateStatus = "v\(update.version) Available!"
                    if let url = URL(string: update.url) {
                        NSWorkspace.shared.open(url)
                    }
                case .failed:
                    updateStatus = "Up to date"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.updateStatus = nil
                    }
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let symbol: String
    let tintColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(tintColor.opacity(0.16))
                    .frame(width: 30, height: 30)
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(tintColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
