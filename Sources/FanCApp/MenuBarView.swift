//
//  MenuBarView.swift
//  FanC
//
//  Elevated macOS menu bar dropdown with real-time tachometer gauges,
//  multi-sensor thermal heatmap chips, proactive curve selectors, and
//  integrated About Window access.
//

import SwiftUI
import FanCCore

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Bar
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 24, height: 24)
                    Image(systemName: "fan.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("FanC")
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                Spacer()

                stateIndicatorBadge

                Button {
                    AboutWindowController.shared.show()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("About FanC")
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            Divider()

            // System Status / Banners
            if appState.daemonUnreachable {
                DaemonDownBanner(onRestart: { appState.restartDaemon() })
                    .padding(.horizontal, 12)
            } else {
                if let daemonVersion = appState.daemonVersionMismatch {
                    DaemonUpdateBanner(daemonVersion: daemonVersion)
                        .padding(.horizontal, 12)
                }
                if let hold = appState.externalHold {
                    ExternalHoldBanner(hold: hold)
                        .padding(.horizontal, 12)
                }
                if appState.daemonVersionMismatch == nil, let update = appState.availableUpdate {
                    UpdateAvailableBanner(update: update, onDismiss: { appState.dismissUpdate() })
                        .padding(.horizontal, 12)
                }
            }

            // Fan Speed Tachometer Section
            if let status = appState.latestStatus {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("ACTIVE FANS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)

                    VStack(spacing: 6) {
                        ForEach(status.fans, id: \.index) { fan in
                            FanGaugeRow(fan: fan)
                        }
                    }
                    .padding(.horizontal, 12)
                }

                // Temperatures Heatmap Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("THERMAL SENSORS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        if let maxC = appState.maxTemp {
                            let disp = appState.useFahrenheit ? maxC * 9 / 5 + 32 : maxC
                            let unit = appState.useFahrenheit ? "°F" : "°C"
                            Text("Peak: \(Int(disp))\(unit)")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(tempColor(maxC))
                        }
                    }
                    .padding(.horizontal, 14)

                    ThermalGrid(
                        cpu: peakTemp(prefixes: ["TC", "Tp"]),
                        gpu: peakTemp(prefixes: ["TG", "Tg"]),
                        ram: peakTemp(prefixes: ["TR", "Tm", "TM"]),
                        ssd: peakTemp(prefixes: ["TH"]),
                        ambient: peakTemp(prefixes: ["TA"]),
                        useFahrenheit: appState.useFahrenheit
                    )
                    .padding(.horizontal, 12)
                }
            } else {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Reading SMC hardware sensors...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(14)
            }

            Divider()

            // Profiles Section
            VStack(alignment: .leading, spacing: 6) {
                Text("FAN PROFILE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 14)

                VStack(spacing: 4) {
                    ForEach(FanProfile.builtIn) { profile in
                        ProfileRowButton(
                            profile: profile,
                            isSelected: appState.activeProfile.id == profile.id,
                            useFahrenheit: appState.useFahrenheit
                        ) {
                            appState.selectProfile(profile)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            Divider()

            // Quick Actions Bar
            HStack(spacing: 8) {
                // Smart Proactive Quick Toggle
                Button {
                    if appState.activeProfile.id == "smart" {
                        appState.resetAuto()
                    } else {
                        appState.setSmart()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                        Text(appState.activeProfile.id == "smart" ? "Smart Active" : "Enable Smart")
                            .font(.system(size: 11.5, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(appState.activeProfile.id == "smart" ? Color.cyan : Color.cyan.opacity(0.15))
                    .foregroundColor(appState.activeProfile.id == "smart" ? .black : .cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)

                // Default Auto Button
                Button {
                    appState.resetAuto()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                        Text("Apple Default")
                            .font(.system(size: 11.5, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.15))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)

            Divider()

            // Preferences & Footer
            VStack(spacing: 4) {
                HStack {
                    Toggle("Display in Fahrenheit (°F)", isOn: $appState.useFahrenheit)
                        .font(.system(size: 11.5))
                    Spacer()
                }

                HStack {
                    Toggle("Launch at Login", isOn: $appState.launchAtLogin)
                        .font(.system(size: 11.5))
                    Spacer()
                }

                HStack {
                    Text("FanC v\(FanCVersion.current)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.7))

                    Spacer()

                    Button("Quit FanC") {
                        NSApp.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .frame(width: 310)
    }

    // MARK: - Subviews & Indicators

    @ViewBuilder
    private var stateIndicatorBadge: some View {
        switch appState.monitorState {
        case .safetyOverride:
            HStack(spacing: 4) {
                Circle().fill(Color.red).frame(width: 6, height: 6)
                Text("SAFETY 95°C")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.red.opacity(0.15))
            .clipShape(Capsule())

        case .active(let name):
            HStack(spacing: 4) {
                Circle().fill(Color.orange).frame(width: 6, height: 6)
                Text(name.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())

        case .idle:
            HStack(spacing: 4) {
                Circle().fill(Color.secondary).frame(width: 6, height: 6)
                Text("APPLE AUTO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())
        }
    }

    private func peakTemp(prefixes: [String]) -> Float? {
        guard let temps = appState.latestStatus?.temperatures else { return nil }
        let values = temps.filter { key, _ in prefixes.contains(where: { key.hasPrefix($0) }) }.values
        return values.max()
    }
}

// MARK: - Fan Gauge Row

private struct FanGaugeRow: View {
    let fan: ThermalStatus.FanStatus

    private var percentage: Double {
        guard fan.maxRPM > fan.minRPM else { return 0.0 }
        let clamped = max(fan.minRPM, min(fan.actualRPM, fan.maxRPM))
        return Double(clamped - fan.minRPM) / Double(fan.maxRPM - fan.minRPM)
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "fan.fill")
                    .font(.system(size: 11))
                    .foregroundColor(percentage > 0.6 ? .orange : .teal)

                Text("Fan \(fan.index)")
                    .font(.system(size: 12, weight: .medium))

                Spacer()

                Text("\(fan.actualRPM) RPM")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))

                Text("(\(Int(percentage * 100))%)")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            // Animated Visual Gradient Gauge Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.teal, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, geo.size.width * CGFloat(percentage)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Thermal Heatmap Grid

private struct ThermalGrid: View {
    let cpu: Float?
    let gpu: Float?
    let ram: Float?
    let ssd: Float?
    let ambient: Float?
    let useFahrenheit: Bool

    var body: some View {
        HStack(spacing: 6) {
            ThermalChip(label: "CPU", tempC: cpu, useFahrenheit: useFahrenheit)
            ThermalChip(label: "GPU", tempC: gpu, useFahrenheit: useFahrenheit)
            ThermalChip(label: "RAM", tempC: ram, useFahrenheit: useFahrenheit)
            ThermalChip(label: "SSD", tempC: ssd, useFahrenheit: useFahrenheit)
            ThermalChip(label: "Ambient", tempC: ambient, useFahrenheit: useFahrenheit)
        }
    }
}

private struct ThermalChip: View {
    let label: String
    let tempC: Float?
    let useFahrenheit: Bool

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundColor(.secondary)

            if let c = tempC {
                let disp = useFahrenheit ? c * 9 / 5 + 32 : c
                Text("\(Int(disp))°")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(tempColor(c))
            } else {
                Text("—")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

private func tempColor(_ temp: Float) -> Color {
    if temp >= 90 { return .red }
    if temp >= 75 { return .orange }
    if temp >= 60 { return .yellow }
    return .teal
}

// MARK: - Profile Selector Button

private struct ProfileRowButton: View {
    let profile: FanProfile
    let isSelected: Bool
    let useFahrenheit: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconFor(profile.id))
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .cyan : .secondary)
                    .frame(width: 16)

                Text(profile.name)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)

                Spacer()

                if !profile.curve.handsOff {
                    let unit = useFahrenheit ? "°F" : "°C"
                    if profile.curve.instantEngage {
                        let startC = profile.curve.startTemp
                        let startDisp = useFahrenheit ? startC * 9 / 5 + 32 : startC
                        Text("\(Int(startDisp))\(unit) instant")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    } else {
                        let startC = profile.curve.startTemp
                        let ceilC = profile.curve.ceilingTemp
                        let startDisp = useFahrenheit ? startC * 9 / 5 + 32 : startC
                        let ceilDisp = useFahrenheit ? ceilC * 9 / 5 + 32 : ceilC
                        Text("\(Int(startDisp))→\(Int(ceilDisp))\(unit)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Auto")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .background(isSelected ? Color.cyan.opacity(0.12) : Color.white.opacity(0.001))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(isSelected ? Color.cyan.opacity(0.35) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconFor(_ id: String) -> String {
        switch id {
        case "silent": return "apple.logo"
        case "balanced": return "scale.3d"
        case "performance": return "bolt.shield.fill"
        case "max": return "flame.fill"
        case "smart": return "brain.head.profile"
        default: return "fan.fill"
        }
    }
}

// MARK: - Existing Banners

private struct ExternalHoldBanner: View {
    let hold: DaemonHoldState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Fans held from Terminal", systemImage: "terminal.fill")
                .font(.caption.bold())
                .foregroundColor(.orange)

            Text(describe(hold.command))
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Press Apple Default below to release.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func describe(_ command: String?) -> String {
        let parts = (command ?? "").split(separator: " ").map(String.init)
        switch parts.first {
        case "max":
            return "Fans held at maximum RPM."
        case "set" where parts.count > 1:
            return "Fans held at ~\(parts[1]) RPM."
        case "setfan" where parts.count > 2:
            return "Fan \(parts[1]) held at ~\(parts[2]) RPM."
        default:
            return "Fans held manually from CLI."
        }
    }
}

private struct DaemonUpdateBanner: View {
    let daemonVersion: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Daemon Update Needed", systemImage: "exclamationmark.triangle.fill")
                .font(.caption.bold())
                .foregroundColor(.orange)

            Text("Daemon is running \(daemonVersion), but FanC is \(FanCVersion.current).")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Run: sudo fanc install")
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.secondary.opacity(0.15)))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

private struct UpdateAvailableBanner: View {
    let update: AvailableUpdate
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label("Update Available", systemImage: "arrow.down.circle.fill")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                Spacer()
                Button("Dismiss", action: onDismiss)
                    .buttonStyle(.plain)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Text("FanC \(update.version) is now available.")
                .font(.caption)
                .foregroundColor(.secondary)

            if let url = URL(string: update.url) {
                Link("View Release Notes", destination: url)
                    .font(.caption2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

private struct DaemonDownBanner: View {
    let onRestart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Fan Control Offline", systemImage: "exclamationmark.octagon.fill")
                .font(.caption.bold())
                .foregroundColor(.red)

            Text("The background daemon isn't responding.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: onRestart) {
                Label("Restart Daemon", systemImage: "arrow.clockwise")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
