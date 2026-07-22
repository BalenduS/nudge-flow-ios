import AppKit

let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()
guard let context = NSGraphicsContext.current?.cgContext else {
    fatalError("No graphics context")
}

let rect = CGRect(x: 0, y: 0, width: size, height: size)
let colors = [
    NSColor(red: 0.58, green: 0.36, blue: 0.91, alpha: 1).cgColor,
    NSColor(red: 0.86, green: 0.35, blue: 0.76, alpha: 1).cgColor
] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

context.setStrokeColor(NSColor.white.cgColor)
context.setLineWidth(88)
context.setLineCap(.round)
let center = CGPoint(x: size / 2, y: size / 2)
context.addArc(center: center, radius: 330, startAngle: .pi / 2, endAngle: .pi / 2 - .pi * 1.5, clockwise: true)
context.strokePath()

context.setFillColor(NSColor.white.cgColor)
context.fillEllipse(in: CGRect(x: 128, y: 474, width: 112, height: 112))

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not render png")
}

let output = URL(fileURLWithPath: "NudgeFlow/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
try png.write(to: output)
