# Brag Plan: FanC

## What is this app?
FanC is an intelligent, proactive fan control and thermal engine for Apple Silicon Macs (M1 through M6) that learns thermal rates of change and ramps cooling before CPU/GPU throttling starts.

## The angle
Legacy fan control apps like Macs Fan Control and TG Pro charge $15–$20 for 10-year-old single-sensor linear curves that wait until your Mac is already boiling before speeding up fans. FanC rethinks cooling from first principles: proactive multi-cluster rate-of-change sensing, 120Hz tachometer & heatmap UI, daemon-level 95°C safety floors, and 100% free open-source code for Apple Silicon.

## Hook (first 2-3 seconds)
A blazing hot thermometer crossing 95°C with the CPU throttling warning.
Headline: *"Why does your $2,000 Mac wait until it's already throttling before turning on the fans?"*
Cut abruptly to: *"Cool your Mac before it slows down. Meet FanC."*

## Key moments (the middle)
- **Proactive Adaptive Curve:** S-curves and rate-of-change sensing ramp fans proactively instead of reacting after the chip gets hot.
- **120Hz Tachometer & Cluster Heatmap:** Sleek dark-mode SwiftUI interface displaying real-time RPMs and temperatures across CPU, GPU, RAM, SSD, and ambient sensors.
- **Daemon Safety Invariants:** 95°C emergency override and crash watchdog enforced in a root daemon—fans stay safe even if the app crashes or closes.

## Outro / punchline
*"Maximum performance. Zero thermal throttle."*
1-Line Terminal Install:
`curl -fsSL https://raw.githubusercontent.com/arunofhyd/FanC/main/install-fanc.command | bash`
Subtext: `Native Swift Menu Bar + CLI · M1 to M6 Apple Silicon · Free & Open Source`

## User flow worth showing
1. **Entry:** Heavy render/build job starts → Mac CPU temperature spikes rapidly.
2. **Action:** FanC's proactive rate-of-change engine catches thermal velocity and smoothly ramps fans early.
3. **Result:** Core temps stay locked at 68°C with zero thermal throttling and whisper-quiet acoustic curves.

## Tone
- **Preset:** `polished`
- **Creative direction:** High-performance Apple Silicon engineering film: obsidian glass, emerald cooling neon, tachometer RPM motion, clean hardware diagrams.

## Format: landscape — 1920x1080
## Duration: 20s

## Visual identity (from the project)
- **Background:** `#0b0d10`
- **Surface:** `#15181d` with 1px border `rgba(255, 255, 255, 0.1)`
- **Accent Emerald:** `#34C759` (Optimal cooling)
- **Accent Thermal Red:** `#FF3B30` (High heat alerts)
- **Accent Heat Orange:** `#FF9F0A`
- **Fonts:** `Inter` & `Fira Code`

## Share copy (draft)
Stop letting your Apple Silicon Mac throttle before fans kick in. FanC brings intelligent, proactive thermal control to M1–M6 Macs with 120Hz tachometers and daemon safety. 100% Free & Open Source. ❄️🚀

## Audio direction
- **Role:** High-tech driving pulse with subtle wind/fan whooshes and crisp UI switches.
- **Music:** `happy-beats-business-moves-vol-12-by-ende-dot-app.mp3`

## Storyboard
- **Scene 1 (0.0s – 3.0s):** The Thermal Throttle Trap — 95°C CPU spike vs passive fans.
- **Scene 2 (3.0s – 7.5s):** Meet FanC — 120Hz tachometer & menu bar interface reveal.
- **Scene 3 (7.5s – 12.5s):** Proactive Adaptive Curves — Multi-sensor matrix across CPU/GPU clusters.
- **Scene 4 (12.5s – 17.0s):** Daemon-Level Safety — 95°C hardware floor + CLI access.
- **Scene 5 (17.0s – 20.0s):** Outro & 1-Command Install — FanC icon, MIT license, install string.
