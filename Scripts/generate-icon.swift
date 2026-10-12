#!/usr/bin/env swift
//
//  generate-icon.swift
//  FanC
//
//  Generates a state-of-the-art macOS squircle AppIcon for FanC.
//

import AppKit

func renderIcon(size: Int, scale: Int = 1) -> NSImage {
    let px = size * scale
    let s = CGFloat(px)
    let image = NSImage(size: NSSize(width: px, height: px))
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let rect = NSRect(x: 0, y: 0, width: s, height: s)

    // Squircle clipping path (Apple standard corner radius ~ 22.37%)
    let cornerRadius = s * 0.224
    let squirclePath = NSBezierPath(roundedRect: rect.insetBy(dx: s * 0.04, dy: s * 0.04),
                                    xRadius: cornerRadius,
                                    yRadius: cornerRadius)

    context.saveGState()
    squirclePath.addClip()

    // Background: Deep obsidian space gradient
    let bgGradient = NSGradient(colors: [
        NSColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1.0),
        NSColor(red: 0.04, green: 0.05, blue: 0.07, alpha: 1.0)
    ])!
    bgGradient.draw(in: rect, angle: -45)

    // Subtle arctic cooling ambient radial glow from center
    let center = CGPoint(x: s * 0.5, y: s * 0.5)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let glowColors = [
        NSColor(red: 0.0, green: 0.88, blue: 1.0, alpha: 0.38).cgColor,
        NSColor(red: 0.08, green: 0.55, blue: 0.98, alpha: 0.20).cgColor,
        NSColor.clear.cgColor
    ] as CFArray
    if let radial = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 0.45, 1.0]) {
        context.drawRadialGradient(radial,
                                   startCenter: center,
                                   startRadius: 0,
                                   endCenter: center,
                                   endRadius: s * 0.45,
                                   options: [])
    }

    // Outer subtle metallic bezel ring
    let bezelPath = squirclePath
    NSColor(white: 1.0, alpha: 0.12).setStroke()
    bezelPath.lineWidth = s * 0.015
    bezelPath.stroke()

    // Inner turbine fan symbol
    let symbolSize = s * 0.52
    let config = NSImage.SymbolConfiguration(pointSize: symbolSize, weight: .semibold)
    if let symbol = NSImage(systemSymbolName: "fan.fill", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
        let symRect = symbol.size
        let originX = (s - symRect.width) / 2
        let originY = (s - symRect.height) / 2 - s * 0.01

        // Render turbine with glowing electric ice cyan to frost azure gradient
        let tinted = NSImage(size: symRect)
        tinted.lockFocus()
        symbol.draw(in: NSRect(origin: .zero, size: symRect))

        // Linear gradient overlay on symbol
        if let symCtx = NSGraphicsContext.current?.cgContext {
            symCtx.setBlendMode(.sourceIn)
            let symGradientColors = [
                NSColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,   // Electric ice cyan
                NSColor(red: 0.1, green: 0.65, blue: 1.0, alpha: 1.0).cgColor,   // Frost azure
                NSColor(red: 0.15, green: 0.42, blue: 0.95, alpha: 1.0).cgColor  // Deep royal cobalt
            ] as CFArray
            if let symGrad = CGGradient(colorsSpace: colorSpace, colors: symGradientColors, locations: [0.0, 0.5, 1.0]) {
                symCtx.drawLinearGradient(symGrad,
                                          start: CGPoint(x: 0, y: symRect.height),
                                          end: CGPoint(x: symRect.width, y: 0),
                                          options: [])
            }
        }
        tinted.unlockFocus()

        // Drop shadow for turbine with electric cyan glow
        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: -s * 0.02), blur: s * 0.04, color: NSColor(red: 0.0, green: 0.88, blue: 1.0, alpha: 0.50).cgColor)
        tinted.draw(in: NSRect(x: originX, y: originY, width: symRect.width, height: symRect.height))
        context.restoreGState()
    }

    // High-tech center metallic bearing cap
    let capRadius = s * 0.065
    let capRect = NSRect(x: s * 0.5 - capRadius, y: s * 0.5 - capRadius - s * 0.01, width: capRadius * 2, height: capRadius * 2)
    let capPath = NSBezierPath(ovalIn: capRect)
    let capGradient = NSGradient(colors: [
        NSColor(white: 0.90, alpha: 1.0),
        NSColor(white: 0.40, alpha: 1.0)
    ])!
    capGradient.draw(in: capPath, angle: -45)

    // Inner bright electric cyan center dot
    let innerDot = NSBezierPath(ovalIn: capRect.insetBy(dx: capRadius * 0.45, dy: capRadius * 0.45))
    NSColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0).setFill()
    innerDot.fill()

    context.restoreGState()
    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:])
    else { return }
    try! png.write(to: URL(fileURLWithPath: path))
}

let iconsetPath = "FanC.iconset"
try? FileManager.default.removeItem(atPath: iconsetPath)
try! FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

let sizes = [16, 32, 128, 256, 512]
for size in sizes {
    savePNG(renderIcon(size: size), to: "\(iconsetPath)/icon_\(size)x\(size).png")
    savePNG(renderIcon(size: size, scale: 2), to: "\(iconsetPath)/icon_\(size)x\(size)@2x.png")
}

// 1024x1024 AppIcon.png for repository and documentation
savePNG(renderIcon(size: 512, scale: 2), to: "AppIcon.png")

print("Generated iconset at \(iconsetPath) and AppIcon.png")
