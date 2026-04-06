import SwiftUI

struct DominoTileView: View {
    var width: CGFloat = 50
    var height: CGFloat = 100

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let r: CGFloat = w / 6
            let inset: CGFloat = w / 30
            let divY = h / 2

            let tileRect = CGRect(x: inset, y: inset, width: w - inset * 2, height: h - inset * 2)
            let tilePath = Path(roundedRect: tileRect, cornerRadius: r - 1)

            // Shadow base
            context.drawLayer { ctx in
                ctx.addFilter(.shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 4))
                ctx.fill(tilePath, with: .color(Color(red: 0.72, green: 0.67, blue: 0.56)))
            }

            // Surface gradient (warm ivory)
            let surfaceGradient = Gradient(stops: [
                .init(color: Color(red: 0.98, green: 0.96, blue: 0.92), location: 0),
                .init(color: Color(red: 0.93, green: 0.89, blue: 0.80), location: 0.45),
                .init(color: Color(red: 0.81, green: 0.75, blue: 0.64), location: 1)
            ])
            context.fill(tilePath, with: .linearGradient(
                surfaceGradient,
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: w, y: h)
            ))

            // Bevel: vertical overlay
            context.drawLayer { ctx in
                ctx.clip(to: tilePath)
                let bevelV = Gradient(stops: [
                    .init(color: Color.white.opacity(0.55), location: 0),
                    .init(color: Color.white.opacity(0), location: 0.30),
                    .init(color: Color.black.opacity(0.18), location: 1)
                ])
                ctx.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(bevelV, startPoint: .zero, endPoint: CGPoint(x: 0, y: h))
                )
            }

            // Bevel: horizontal overlay
            context.drawLayer { ctx in
                ctx.clip(to: tilePath)
                let bevelH = Gradient(stops: [
                    .init(color: Color.white.opacity(0.3), location: 0),
                    .init(color: Color.white.opacity(0), location: 0.30),
                    .init(color: Color.black.opacity(0.1), location: 1)
                ])
                ctx.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(bevelH, startPoint: .zero, endPoint: CGPoint(x: w, y: 0))
                )
            }

            // Outer edge stroke
            context.stroke(tilePath, with: .color(Color(red: 0.66, green: 0.60, blue: 0.48)), lineWidth: 1)

            // Inner highlight rim
            let innerRect = tileRect.insetBy(dx: 2, dy: 2)
            let innerPath = Path(roundedRect: innerRect, cornerRadius: r - 3)
            context.stroke(innerPath, with: .color(Color.white.opacity(0.35)), lineWidth: 0.8)

            // Divider groove
            let grooveX1 = w * 0.13
            let grooveX2 = w * 0.87
            var darkLine = Path()
            darkLine.move(to: CGPoint(x: grooveX1, y: divY))
            darkLine.addLine(to: CGPoint(x: grooveX2, y: divY))
            context.stroke(darkLine, with: .color(Color(red: 0.54, green: 0.48, blue: 0.37)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))

            var lightLine = Path()
            lightLine.move(to: CGPoint(x: grooveX1, y: divY + 1.2))
            lightLine.addLine(to: CGPoint(x: grooveX2, y: divY + 1.2))
            context.stroke(lightLine, with: .color(Color(red: 1, green: 0.98, blue: 0.91).opacity(0.45)), style: StrokeStyle(lineWidth: 0.6, lineCap: .round))

            // Pip positions (matching SVG: cols=[18,42]/60, rows=[15,30,45]/60)
            let cols = [w * 0.30, w * 0.70]
            let rows = [0.25, 0.50, 0.75]
            let pr = w * 0.093

            let pipGradient = Gradient(stops: [
                .init(color: Color(red: 0.18, green: 0.12, blue: 0.05), location: 0),
                .init(color: Color(red: 0.09, green: 0.05, blue: 0.02), location: 0.70),
                .init(color: Color(red: 0.05, green: 0.03, blue: 0.02), location: 1)
            ])

            func drawPips(yOffset: CGFloat) {
                let halfH = h / 2
                for row in rows {
                    for col in cols {
                        let cx = col
                        let cy = row * halfH + yOffset

                        // Carved shadow ring
                        let shadowPath = Path(ellipseIn: CGRect(
                            x: cx - (pr + 0.8), y: cy - (pr + 0.8),
                            width: (pr + 0.8) * 2, height: (pr + 0.8) * 2
                        ))
                        context.fill(shadowPath, with: .color(Color.black.opacity(0.19)))

                        // Pip bowl
                        let pipPath = Path(ellipseIn: CGRect(
                            x: cx - pr, y: cy - pr,
                            width: pr * 2, height: pr * 2
                        ))
                        context.fill(pipPath, with: .radialGradient(
                            pipGradient,
                            center: CGPoint(x: cx - pr * 0.24, y: cy - pr * 0.36),
                            startRadius: 0,
                            endRadius: pr * 1.3
                        ))

                        // Rim highlight (top-left crescent)
                        let hlR = pr * 0.55
                        let hlPath = Path(ellipseIn: CGRect(
                            x: cx - 1.4 - hlR, y: cy - 1.4 - hlR,
                            width: hlR * 2, height: hlR * 2
                        ))
                        context.fill(hlPath, with: .color(Color.white.opacity(0.09)))
                    }
                }
            }

            drawPips(yOffset: 0)
            drawPips(yOffset: divY)
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    DominoTileView()
        .preferredColorScheme(.dark)
}
