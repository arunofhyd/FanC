# FanC

<p align="center">
  <img src="AppIcon.png" alt="FanC Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);" />
</p>

<p align="center">
  <strong>Intelligent, Proactive Fan Control & Thermal Engine for Apple Silicon Macs (M1, M2, M3, M4, M5, M6).</strong><br>
  Menu Bar App + High-Performance CLI + Privileged Daemon.
</p>

<p align="center">
  Built with Swift by <a href="https://github.com/arunofhyd">Arun Thomas</a>.<br>
  No subscriptions, zero telemetry, no ads, completely open source.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://www.apple.com/macos/"><img src="https://img.shields.io/badge/macOS-14%2B-black?logo=apple" alt="macOS 14+"></a>
  <a href="https://support.apple.com/en-us/116943"><img src="https://img.shields.io/badge/Apple%20Silicon-M1%2C%20M2%2C%20M3%2C%20M4%2C%20M5%2C%20M6-orange" alt="Apple Silicon"></a>
  <a href="https://github.com/arunofhyd/FanC/releases/latest"><img src="https://img.shields.io/badge/release-v1.0.0-emerald" alt="Release v1.0.0"></a>
</p>

---

## Why FanC?

Traditional tools like **Macs Fan Control** and **TG Pro** charge $15–$20 for legacy fan management software that has barely evolved in years. Both require manual tuning, monitor only single sensors, and frequently encounter compatibility issues with modern Apple Silicon M-series chips.

**FanC** rethinks thermal engineering for Apple Silicon from first principles:

| Feature | FanC | Macs Fan Control | TG Pro |
|---|---|---|---|
| **Smart Adaptive Fan Curve** | **Yes (Rate-of-change aware)** | No | No |
| **Multi-Sensor Safety Matrix** | **Yes — all thermal clusters** | [1 sensor per fan](https://github.com/crystalidea/macs-fan-control/issues/266) | Manual rules only |
| **Proactive Cooling** (ramps before throttling) | **Yes** | No | No |
| **Animated Tachometer & Heatmap UI** | **Yes (SwiftUI 120Hz)** | Static text | Generic graphs |
| **Fan Curve Shapes** | **Ease-in (pos²), linear, S-curve, instant** | 2-point linear | Step-function |
| **Real-time Sensor Monitoring** | **Yes (CPU, GPU, RAM, SSD, Ambient)** | Yes | Yes |
| **Menu Bar App** | **Yes** | Yes | Yes |
| **CLI Access** | **Yes (`fanc`)** | No | No |
| **Thermal Telemetry Export** (CSV/JSON) | **Yes** | No | Yes |
| **Sleep/Wake Re-apply** | **Yes (IOKit power hooks)** | Yes | Yes |
| **Daemon 95°C Safety Override** | **Yes — daemon-enforced (works even with app closed)** | No | Manual setup |
| **Crash Recovery Watchdog** | **Yes — resets fans to Apple defaults if app terminates** | Reverts on quit only | Overrides remove safety |
| **Standard Bundle ID (`com.aoh.fanc`)** | **Yes (Preserves TCC permissions across updates)** | No | No |
| **Price & License** | **Free & Open Source (MIT)** | $15 | $20 |

---

## ✨ Features

- **Liquid Native Menu Bar Interface**: Visual fan tachometers with animated RPM gauges (% power output) and thermal sensor heatmap chips (CPU, GPU, RAM, SSD, Ambient).
- **Proactive Cooling Engine**: Continuously evaluates temperature acceleration ($\frac{dT}{dt}$) and engages fans before the processor reaches thermal throttling trip points.
- **5 Tuned Profiles**:
  - 🍏 **Default (Apple Default)**: Zero intervention; macOS firmware thermal manager controls fans.
  - ⚖️ **Balanced**: Quiet at idle, proportional $pos^2$ ease-in curve as heat accumulates.
  - ⚡ **Performance**: Direct linear response with $2\times$ ramp-up velocity for compiling & rendering.
  - 🚀 **Max**: Instant 100% cooling power when triggered, gradual controlled governor ramp-down.
  - 🧠 **Smart**: Intelligent S-curve with rate-of-change awareness. Engages early to suppress thermal spikes.
- **Dual-Layer Hardware Safety**:
  - **95°C Thermal Floor**: Enforced directly inside the background daemon (`/var/run/fanc.sock`), forcing fans to 100% if any sensor reaches 95°C even if a manual override was set.
  - **Heartbeat Watchdog**: If the app or terminal session crashes, the daemon safely returns fans to Apple hardware defaults within 15 seconds.
- **Full CLI Suite (`fanc`)**: Query status, set RPMs, trigger calibrations, stream telemetry, and manage daemons directly from zsh/bash.
- **Signature About Window**: Native frosted glass popover with live version introspection, one-click update checking, and developer contact.

---

## Profiles Breakdown

All profiles share a unified **50°C** off threshold matching Apple's acoustic targets. Polling runs at **100ms** (matching Apple's `thermalmonitord` cadence).

| Profile | Fans Off | Fans Start | Ceiling | Max Fan | Curve Shape | Sustained Trigger | Personality |
|---|---|---|---|---|---|---|---|
| **Silent** | N/A | N/A | N/A | Apple | N/A | N/A | Monitoring only. Apple controls fans. |
| **Balanced** | 50°C | 55°C | 70°C | 60% | Ease-in ($pos^2$) | 8 seconds | Silent at low loads, ramps smoothly. |
| **Performance** | 50°C | 55°C | 65°C | 85% | Linear | 4 seconds | Quick reaction, heavy sustained workloads. |
| **Max** | 50°C | 65°C | — | 100% | Instant | 5 seconds | 100% turbine blast for extreme exports. |
| **Smart** | 50°C | 53°C | 85°C | 100% | S-Curve | 6 seconds | Predictive rate-of-change cooling. |

---

## 🚀 Quick Install

### Option A: From Source (Recommended)

```bash
git clone https://github.com/arunofhyd/FanC.git
cd FanC
./setup.sh
```

`setup.sh` automatically compiles the native Swift binaries locally (so Gatekeeper never blocks them), sets up the background daemon, and installs **`FanC.app`** into `/Applications`.

### Option B: Local Developer Build

```bash
./build_app.sh
open .build/release/FanC.app
```

---

## 💻 CLI Usage (`fanc`)

FanC includes a command-line interface:

```bash
# View real-time fan tachometer and sensor temperatures
fanc status

# Continuous monitoring watch mode
fanc watch --interval 1.0

# Set fan profile to Smart Proactive
fanc auto

# Force maximum cooling
sudo fanc max

# Set custom target RPM
sudo fanc set 3500

# Set specific fan index
sudo fanc setfan 0 4000

# Export thermal telemetry session to CSV
fanc log --rate 2 --duration 60s

# Re-calibrate fan response curves for your machine
sudo fanc calibrate
```

---

## 🔒 Security & Architecture

FanC communicates through a privileged background daemon running as root via `launchd`:

- **Private Unix Domain Socket**: The daemon listens on `/var/run/fanc.sock` (mode `0600`), owned by root and your user account. No unauthorized local processes can manipulate fan speeds.
- **Structured Framing Protocol**: Binary frames are strictly validated with message size caps to prevent buffer attacks.
- **TCC Permission Preservation**: Strictly uses standard bundle identifier `com.aoh.fanc` to ensure macOS permissions persist seamlessly across all future updates.

---

## 🙏 Acknowledgments & Upstream Heritage

FanC is proudly built upon and inspired by the foundational low-level SMC thermal control work of **[ThermalForge](https://github.com/ProducerGuy/ThermalForge)** by **[ProducerGuy](https://github.com/ProducerGuy)**.

We extend our deep gratitude to ProducerGuy for open-sourcing the Apple Silicon SMC protocol reverse-engineering and establishing the safety primitives that made native Apple Silicon fan control possible. FanC builds upon this remarkable work with a modernized macOS SwiftUI interface, live visual tachometer gauges, multi-sensor thermal heatmaps, automated update checking, and an elevated user experience.

---

## 👤 Author

**Arun Thomas**
- GitHub: [@arunofhyd](https://github.com/arunofhyd)
- Email: [arunthomas04042001@gmail.com](mailto:arunthomas04042001@gmail.com)

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
