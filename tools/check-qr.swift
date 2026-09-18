// Draws every tag's QR code with the page's own encoder and reads it back with Core Image.
// Run from the repo root on a Mac: swift tools/check-qr.swift
import CoreImage
import Foundation
import JavaScriptCore

let html = try! String(contentsOfFile: "index.html", encoding: .utf8)
let start = html.range(of: "<script>")!.upperBound
let end = html.range(of: "</script>", range: start..<html.endIndex)!.lowerBound
let js = JSContext()!
js.exceptionHandler = { _, error in print("JS error:", error!); exit(1) }
js.evaluateScript(String(html[start..<end]))
let rows = js.evaluateScript("(function (u) { return qrMatrix(u).map(function (r) { return r.map(Number).join(''); }); })")!

let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
var failures = 0
for tag in 0..<1000 {
    let url = String(format: "https://bit.ly/2U1R3rM?id=CONBUS|%03d", tag)
    let matrix = rows.call(withArguments: [url]).toArray() as! [String]
    let px = 8, side = (matrix.count + 8) * px
    var pixels = [UInt8](repeating: 255, count: side * side)
    for (y, row) in matrix.enumerated() {
        for (x, bit) in row.enumerated() where bit == "1" {
            for dy in 0..<px { for dx in 0..<px { pixels[((y + 4) * px + dy) * side + (x + 4) * px + dx] = 0 } }
        }
    }
    let image = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: side,
                        space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: 0),
                        provider: CGDataProvider(data: Data(pixels) as CFData)!, decode: nil,
                        shouldInterpolate: false, intent: .defaultIntent)!
    let decoded = (detector.features(in: CIImage(cgImage: image)).first as? CIQRCodeFeature)?.messageString
    if decoded != url { failures += 1; print("FAIL", url, decoded ?? "nothing") }
}
print(failures == 0 ? "All 1000 tags decode" : "\(failures) tags failed")
exit(failures == 0 ? 0 : 1)
