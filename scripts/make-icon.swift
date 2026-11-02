import AppKit

let image = NSImage(size: NSSize(width: 32, height: 32))
image.lockFocus()
let text = "VI" as NSString
text.draw(at: NSPoint(x: 2, y: 5), withAttributes: [
    .font: NSFont.boldSystemFont(ofSize: 21),
    .foregroundColor: NSColor.labelColor
])
image.unlockFocus()
try image.tiffRepresentation!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
