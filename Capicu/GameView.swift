import SwiftUI

struct GameView: View {
    @Bindable var game: GameModel
    @State private var showCurrentHistory = false
    @State private var expandedGame: Int? = nil

    var body: some View {
        GeometryReader { geo in
            let bottomHeight = geo.size.height * 0.33

            VStack(spacing: 10) {
                ZStack {
                    VStack(spacing: 10) {
                        TeamCardView(
                            name: "Nosotros",
                            score: game.nosotros,
                            remaining: game.nosotrosRemaining,
                            accentColor: Color(red: 0.30, green: 0.79, blue: 0.94),
                            input: $game.nosotrosInput,
                            gameOver: game.gameOver,
                            onAdd: { game.addPoints(team: "nosotros") }
                        )
                        .frame(maxHeight: .infinity)

                        TeamCardView(
                            name: "Ellos",
                            score: game.ellos,
                            remaining: game.ellosRemaining,
                            accentColor: Color(red: 0.97, green: 0.15, blue: 0.52),
                            input: $game.ellosInput,
                            gameOver: game.gameOver,
                            onAdd: { game.addPoints(team: "ellos") }
                        )
                        .frame(maxHeight: .infinity)
                    }

                    if game.winner != nil {
                        winnerOverlay
                    }
                }
                .frame(maxHeight: .infinity)

                scoresPanel
                    .frame(height: bottomHeight)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard)
        .navigationTitle("Dominó Doble Seis")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    game.returnToMenu()
                } label: {
                    Label("Menú", systemImage: "house")
                }
                .buttonStyle(.glass)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    game.undo()
                } label: {
                    Label("Deshacer", systemImage: "arrow.uturn.backward")
                }
                .buttonStyle(.glass)
                .disabled(game.history.isEmpty)
            }
        }
    }

    // MARK: - Scores Panel (collapsible game log + current history)

    private var scoresPanel: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Current game first
                currentGameRow

                // Previous games (newest first)
                ForEach(game.gameLog.reversed()) { result in
                    previousGameRow(result)
                }

                // Empty state
                if game.gameLog.isEmpty && game.history.isEmpty {
                    Text("Los puntajes aparecerán aquí")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    // MARK: - Previous Game Row

    private func previousGameRow(_ result: GameResult) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
                    .frame(width: 18)
                    .rotationEffect(.degrees(expandedGame == result.gameNumber ? 90 : 0))

                Text("Juego \(result.gameNumber)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(result.nosotros)")
                    .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                    .fontWeight(result.winner == "nosotros" ? .bold : .regular)
                Text("–")
                    .foregroundStyle(.tertiary)
                Text("\(result.ellos)")
                    .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                    .fontWeight(result.winner == "ellos" ? .bold : .regular)

                if result.winner == "nosotros" || result.winner == "ellos" {
                    Text("👑")
                        .font(.caption)
                }
            }
            .font(.footnote.monospaced())
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.snappy) {
                    expandedGame = expandedGame == result.gameNumber ? nil : result.gameNumber
                }
            }

            if expandedGame == result.gameNumber {
                VStack(spacing: 0) {
                    ForEach(Array(result.history.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("\(index + 1)")
                                .frame(width: 20, alignment: .center)
                                .foregroundStyle(.tertiary)

                            Spacer()

                            HStack(spacing: 2) {
                                Text("\(entry.nosotros)")
                                if entry.team == "nosotros" {
                                    Text("+\(entry.points)")
                                        .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                                }
                            }
                            .frame(width: 80)

                            HStack(spacing: 2) {
                                Text("\(entry.ellos)")
                                if entry.team == "ellos" {
                                    Text("+\(entry.points)")
                                        .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                                }
                            }
                            .frame(width: 80)
                        }
                        .font(.caption2.weight(.medium).monospaced())
                        .padding(.horizontal, 28)
                        .padding(.vertical, 3)
                    }
                }
                .padding(.bottom, 4)
                .clipped()
                .transition(.opacity)
            }

            Divider().padding(.horizontal, 12)
        }
    }

    // MARK: - Current Game Row

    private var currentGameRow: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                    .rotationEffect(.degrees(showCurrentHistory ? 90 : 0))

                Text("Juego Actual")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(game.nosotros)")
                    .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                    .fontWeight(.bold)
                Text("–")
                    .foregroundStyle(.tertiary)
                Text("\(game.ellos)")
                    .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                    .fontWeight(.bold)
            }
            .font(.callout.monospaced())
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.snappy) {
                    showCurrentHistory.toggle()
                }
            }

            if showCurrentHistory {
                VStack(spacing: 0) {
                    ForEach(Array(game.history.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("\(index + 1)")
                                .frame(width: 20, alignment: .center)
                                .foregroundStyle(.tertiary)

                            Spacer()

                            HStack(spacing: 2) {
                                Text("\(entry.nosotros)")
                                if entry.team == "nosotros" {
                                    Text("+\(entry.points)")
                                        .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                                }
                            }
                            .frame(width: 80)

                            HStack(spacing: 2) {
                                Text("\(entry.ellos)")
                                if entry.team == "ellos" {
                                    Text("+\(entry.points)")
                                        .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                                }
                            }
                            .frame(width: 80)
                        }
                        .font(.caption2.weight(.medium).monospaced())
                        .padding(.horizontal, 28)
                        .padding(.vertical, 3)
                    }
                }
                .clipped()
                .transition(.opacity)
            }
        }
    }

    // MARK: - Winner Overlay

    @ViewBuilder
    private var winnerOverlay: some View {
        if let winner = game.winner {
            let message = winner == "nosotros" ? "NOSOTROS GANAMOS!" : "ELLOS GANARON!"
            let accentColor = winner == "nosotros"
                ? Color(red: 0.30, green: 0.79, blue: 0.94)
                : Color(red: 0.97, green: 0.15, blue: 0.52)

            VStack(spacing: 20) {
                Spacer()

                Text("👑")
                    .font(.system(size: 56))

                Text(message)
                    .font(.title2.weight(.black))
                    .foregroundStyle(accentColor)

                HStack(spacing: 16) {
                    Text("\(game.nosotros)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                    Text("–")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text("\(game.ellos)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                }

                Spacer()

                Button {
                    game.startNewGame()
                } label: {
                    Label("Juego Nuevo", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.glassProminent)
                .tint(Color(red: 0.95, green: 0.45, blue: 0.17))

                Button {
                    game.returnToMenu()
                } label: {
                    Text("Volver al Menú")
                        .font(.subheadline)
                }
                .buttonStyle(.glass)
            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
            .phaseAnimator([false, true]) { content, phase in
                content.scaleEffect(phase ? 1.02 : 1.0)
            } animation: { _ in .easeInOut(duration: 0.8) }
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    NavigationStack {
        GameView(game: GameModel())
    }
    .preferredColorScheme(.dark)
}
