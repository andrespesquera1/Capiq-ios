import SwiftUI

struct ContentView: View {
    @State private var game = GameModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        winnerBanner
                        scoreboardSection
                        historySection
                        gameLogSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                actionBar
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("🇩🇴 🇨🇺 🇵🇷")
                .font(.title3)

            HStack(spacing: 12) {
                dominoTile
                dominoTile
            }

            Text("Dominó Doble Seis")
                .font(.title.weight(.heavy))

            Text("Primero en llegar a 200 gana")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Domino Tile

    // Domino tile drawn with Canvas to precisely match the original SVG
    private var dominoTile: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let r: CGFloat = w / 6        // corner radius
            let inset: CGFloat = w / 30    // edge inset
            let divY = h / 2

            let tileRect = CGRect(x: inset, y: inset, width: w - inset * 2, height: h - inset * 2)
            let tilePath = Path(roundedRect: tileRect, cornerRadius: r - 1)

            // -- Shadow base --
            context.drawLayer { ctx in
                ctx.addFilter(.shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 4))
                ctx.fill(tilePath, with: .color(Color(red: 0.72, green: 0.67, blue: 0.56)))
            }

            // -- Surface gradient (warm ivory, top-left to bottom-right) --
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

            // -- Bevel: vertical overlay (top bright → bottom dark) --
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

            // -- Bevel: horizontal overlay (left bright → right dark) --
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

            // -- Outer edge stroke --
            context.stroke(tilePath, with: .color(Color(red: 0.66, green: 0.60, blue: 0.48)), lineWidth: 1)

            // -- Inner highlight rim --
            let innerRect = tileRect.insetBy(dx: 2, dy: 2)
            let innerPath = Path(roundedRect: innerRect, cornerRadius: r - 3)
            context.stroke(innerPath, with: .color(Color.white.opacity(0.35)), lineWidth: 0.8)

            // -- Divider groove --
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

            // -- Pip positions (matching SVG: cols=[18,42]/60, rows=[15,30,45]/60) --
            let cols = [w * 0.30, w * 0.70]
            let rows = [0.25, 0.50, 0.75]    // fractions of half-height
            let pr = w * 0.093               // pip radius (5.6/60)

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
        .frame(width: 50, height: 100)
    }

    // MARK: - Winner Banner

    @ViewBuilder
    private var winnerBanner: some View {
        if let winner = game.winner {
            let name = winner == "nosotros" ? "Nosotros" : "Ellos"
            Text("👑 \(name.uppercased()) GANA! 👑")
                .font(.title3.weight(.black))
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.78, blue: 0.31),
                            Color(red: 0.95, green: 0.45, blue: 0.17)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .phaseAnimator([false, true]) { content, phase in
                    content.scaleEffect(phase ? 1.02 : 1.0)
                } animation: { _ in .easeInOut(duration: 0.8) }
        }
    }

    // MARK: - Scoreboard (vertical stack)

    private var scoreboardSection: some View {
        VStack(spacing: 14) {
            TeamCardView(
                name: "Nosotros",
                score: game.nosotros,
                remaining: game.nosotrosRemaining,
                accentColor: Color(red: 0.30, green: 0.79, blue: 0.94),
                input: $game.nosotrosInput,
                gameOver: game.gameOver,
                onAdd: { game.addPoints(team: "nosotros") }
            )

            TeamCardView(
                name: "Ellos",
                score: game.ellos,
                remaining: game.ellosRemaining,
                accentColor: Color(red: 0.97, green: 0.15, blue: 0.52),
                input: $game.ellosInput,
                gameOver: game.gameOver,
                onAdd: { game.addPoints(team: "ellos") }
            )
        }
    }

    // MARK: - Action Bar (pinned to bottom)

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                game.undo()
            } label: {
                Label("Deshacer", systemImage: "arrow.uturn.backward")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .disabled(game.history.isEmpty)

            Button {
                game.newGame()
            } label: {
                Label("Juego Nuevo", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Color(red: 0.95, green: 0.45, blue: 0.17),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - History

    @ViewBuilder
    private var historySection: some View {
        if !game.history.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Historial")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 0) {
                    HStack {
                        Text("#")
                            .frame(width: 30, alignment: .center)
                        Text("Nosotros")
                            .frame(maxWidth: .infinity)
                        Text("Ellos")
                            .frame(maxWidth: .infinity)
                    }
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)

                    Divider()

                    ForEach(Array(game.history.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("\(index + 1)")
                                .frame(width: 30, alignment: .center)
                                .foregroundStyle(.tertiary)

                            HStack(spacing: 4) {
                                Text("\(entry.nosotros)")
                                if entry.team == "nosotros" {
                                    Text("+\(entry.points)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                                }
                            }
                            .frame(maxWidth: .infinity)

                            HStack(spacing: 4) {
                                Text("\(entry.ellos)")
                                if entry.team == "ellos" {
                                    Text("+\(entry.points)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .font(.callout.weight(.medium).monospaced())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)

                        if index < game.history.count - 1 {
                            Divider().padding(.horizontal, 12)
                        }
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Game Log

    @ViewBuilder
    private var gameLogSection: some View {
        if !game.gameLog.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Juegos de la Noche")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 0) {
                    HStack {
                        Text("#")
                            .frame(width: 30, alignment: .center)
                        Text("Nosotros")
                            .frame(maxWidth: .infinity)
                        Text("Ellos")
                            .frame(maxWidth: .infinity)
                        Text("Ganó")
                            .frame(width: 70, alignment: .center)
                    }
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)

                    Divider()

                    ForEach(game.gameLog) { result in
                        HStack {
                            Text("\(result.gameNumber)")
                                .frame(width: 30, alignment: .center)
                                .foregroundStyle(.tertiary)

                            Text("\(result.nosotros)")
                                .foregroundStyle(result.winner == "nosotros" ? Color(red: 0.30, green: 0.79, blue: 0.94) : .primary)
                                .fontWeight(result.winner == "nosotros" ? .bold : .regular)
                                .frame(maxWidth: .infinity)

                            Text("\(result.ellos)")
                                .foregroundStyle(result.winner == "ellos" ? Color(red: 0.97, green: 0.15, blue: 0.52) : .primary)
                                .fontWeight(result.winner == "ellos" ? .bold : .regular)
                                .frame(maxWidth: .infinity)

                            Text(result.winner == "nosotros" ? "Nos" : result.winner == "ellos" ? "Ellos" : "—")
                                .frame(width: 70, alignment: .center)
                                .foregroundStyle(
                                    result.winner == "nosotros"
                                        ? Color(red: 0.30, green: 0.79, blue: 0.94)
                                        : result.winner == "ellos"
                                            ? Color(red: 0.97, green: 0.15, blue: 0.52)
                                            : .secondary
                                )
                        }
                        .font(.callout.weight(.medium).monospaced())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                    }

                    Divider()

                    HStack {
                        Text("")
                            .frame(width: 30)
                        Text("Ganados: \(game.nosotrosWins)")
                            .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                            .frame(maxWidth: .infinity)
                        Text("Ganados: \(game.ellosWins)")
                            .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                            .frame(maxWidth: .infinity)
                        Text("")
                            .frame(width: 70)
                    }
                    .font(.caption.weight(.bold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    ContentView()
}
