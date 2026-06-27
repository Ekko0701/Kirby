#!/usr/bin/env bash
# Kirby 앱 아이콘 생성기.
# 오로라 그라데이션 배경 + 중앙 검은 원(내부=우주: 성운+별)을 Core Graphics로 1024 렌더 →
# sips로 전 사이즈 생성 → Resources/Assets.xcassets/AppIcon.appiconset 구성.
# 사용법: ./scripts/make-icon.sh
set -euo pipefail
cd "$(dirname "$0")/.."

ICONSET="Resources/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$ICONSET"
MASTER="$(mktemp -d)/icon_1024.png"
SWIFT="$(mktemp -d)/render.swift"

cat > "$SWIFT" <<'SWIFT_EOF'
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let N = 1024
let cs = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: N, height: N, bitsPerComponent: 8,
                    bytesPerRow: 0, space: cs,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

func rgb(_ h: Int, _ a: Double = 1) -> CGColor {
    CGColor(srgbRed: Double((h >> 16) & 0xff)/255, green: Double((h >> 8) & 0xff)/255,
            blue: Double(h & 0xff)/255, alpha: a)
}
func gray(_ w: Double, _ a: Double) -> CGColor { CGColor(srgbRed: w, green: w, blue: w, alpha: a) }

let n = CGFloat(N)
let inset: CGFloat = 84
let body = CGRect(x: inset, y: inset, width: n - 2*inset, height: n - 2*inset)
let radius: CGFloat = 196
let bodyPath = CGPath(roundedRect: body, cornerWidth: radius, cornerHeight: radius, transform: nil)

// 본체 그림자
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -18), blur: 40, color: gray(0, 0.45))
ctx.addPath(bodyPath); ctx.setFillColor(gray(0, 1)); ctx.fillPath()
ctx.restoreGState()

// 오로라 그라데이션 배경
ctx.saveGState()
ctx.addPath(bodyPath); ctx.clip()
let aurora = CGGradient(colorsSpace: cs,
    colors: [rgb(0x7C5CFF), rgb(0x4C7DFF), rgb(0x2DD4BF)] as CFArray,
    locations: [0.0, 0.5, 1.0])!
ctx.drawLinearGradient(aurora,
    start: CGPoint(x: body.minX, y: body.maxY),
    end: CGPoint(x: body.maxX, y: body.minY), options: [])
let sheen = CGGradient(colorsSpace: cs, colors: [gray(1, 0.20), gray(1, 0)] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(sheen, start: CGPoint(x: 0, y: body.maxY),
    end: CGPoint(x: 0, y: body.midY + 60), options: [])
ctx.restoreGState()

// 중앙 검은 원
let c = CGPoint(x: n/2, y: n/2)
let cr: CGFloat = 296

ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 26, color: rgb(0x0A0A12, 0.85))
ctx.addArc(center: c, radius: cr, startAngle: 0, endAngle: .pi*2, clockwise: false)
ctx.setFillColor(rgb(0x05060F)); ctx.fillPath()
ctx.restoreGState()

// 원 내부 = 우주
ctx.saveGState()
ctx.addArc(center: c, radius: cr, startAngle: 0, endAngle: .pi*2, clockwise: false)
ctx.closePath(); ctx.clip()
ctx.setFillColor(rgb(0x05060F)); ctx.fill(CGRect(x: 0, y: 0, width: N, height: N))
let nebula = CGGradient(colorsSpace: cs,
    colors: [rgb(0x7C5CFF, 0.50), rgb(0x2DD4BF, 0.20), rgb(0x05060F, 0)] as CFArray,
    locations: [0.0, 0.5, 1.0])!
ctx.drawRadialGradient(nebula,
    startCenter: CGPoint(x: c.x - 70, y: c.y + 70), startRadius: 0,
    endCenter: c, endRadius: cr*1.15, options: [])
let nebula2 = CGGradient(colorsSpace: cs,
    colors: [rgb(0x4C7DFF, 0.30), rgb(0x05060F, 0)] as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(nebula2,
    startCenter: CGPoint(x: c.x + 90, y: c.y - 80), startRadius: 0,
    endCenter: CGPoint(x: c.x + 90, y: c.y - 80), endRadius: cr*0.8, options: [])

var seed: UInt64 = 0x9E3779B97F4A7C15
func rnd() -> Double {
    seed = seed &* 6364136223846793005 &+ 1442695040888963407
    return Double(seed >> 11) / Double(UInt64(1) << 53)
}
for _ in 0..<160 {
    let ang = rnd() * 2 * Double.pi
    let rad = (rnd().squareRoot()) * Double(cr - 10)
    let x = c.x + CGFloat(cos(ang) * rad)
    let y = c.y + CGFloat(sin(ang) * rad)
    let s = CGFloat(0.5 + rnd() * 2.1)
    ctx.setFillColor(gray(1, 0.35 + rnd() * 0.6))
    ctx.fillEllipse(in: CGRect(x: x - s, y: y - s, width: s*2, height: s*2))
}
let bright = [rgb(0xFFFFFF), rgb(0xBFD0FF), rgb(0xB9FFE9)]
for i in 0..<6 {
    let ang = rnd() * 2 * Double.pi
    let rad = (rnd().squareRoot()) * Double(cr - 30)
    let x = c.x + CGFloat(cos(ang) * rad)
    let y = c.y + CGFloat(sin(ang) * rad)
    let s = CGFloat(2.4 + rnd() * 2.0)
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 8, color: bright[i % 3])
    ctx.setFillColor(bright[i % 3])
    ctx.fillEllipse(in: CGRect(x: x - s, y: y - s, width: s*2, height: s*2))
    ctx.restoreGState()
}
ctx.restoreGState()

ctx.setStrokeColor(gray(1, 0.14)); ctx.setLineWidth(3)
ctx.addArc(center: c, radius: cr, startAngle: 0, endAngle: .pi*2, clockwise: false)
ctx.strokePath()

let image = ctx.makeImage()!
let out = URL(fileURLWithPath: CommandLine.arguments[1])
let dest = CGImageDestinationCreateWithURL(out as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("rendered \(out.path)")
SWIFT_EOF

echo "▶︎ 1024 마스터 렌더…"
swift "$SWIFT" "$MASTER"

echo "▶︎ 사이즈 생성(sips)…"
gen() { sips -z "$1" "$1" "$MASTER" --out "$ICONSET/$2" >/dev/null; }
gen 16  icon_16x16.png
gen 32  icon_16x16@2x.png
gen 32  icon_32x32.png
gen 64  icon_32x32@2x.png
gen 128 icon_128x128.png
gen 256 icon_128x128@2x.png
gen 256 icon_256x256.png
gen 512 icon_256x256@2x.png
gen 512 icon_512x512.png
cp "$MASTER" "$ICONSET/icon_512x512@2x.png"

echo "▶︎ Contents.json…"
cat > "$ICONSET/Contents.json" <<'JSON'
{
  "images" : [
    { "size":"16x16","idiom":"mac","filename":"icon_16x16.png","scale":"1x" },
    { "size":"16x16","idiom":"mac","filename":"icon_16x16@2x.png","scale":"2x" },
    { "size":"32x32","idiom":"mac","filename":"icon_32x32.png","scale":"1x" },
    { "size":"32x32","idiom":"mac","filename":"icon_32x32@2x.png","scale":"2x" },
    { "size":"128x128","idiom":"mac","filename":"icon_128x128.png","scale":"1x" },
    { "size":"128x128","idiom":"mac","filename":"icon_128x128@2x.png","scale":"2x" },
    { "size":"256x256","idiom":"mac","filename":"icon_256x256.png","scale":"1x" },
    { "size":"256x256","idiom":"mac","filename":"icon_256x256@2x.png","scale":"2x" },
    { "size":"512x512","idiom":"mac","filename":"icon_512x512.png","scale":"1x" },
    { "size":"512x512","idiom":"mac","filename":"icon_512x512@2x.png","scale":"2x" }
  ],
  "info" : { "author":"xcode","version":1 }
}
JSON

cat > "Resources/Assets.xcassets/Contents.json" <<'JSON'
{ "info" : { "author":"xcode","version":1 } }
JSON

echo "✓ 아이콘 생성 완료: $ICONSET"
echo "  미리보기: open \"$ICONSET/icon_512x512@2x.png\""
