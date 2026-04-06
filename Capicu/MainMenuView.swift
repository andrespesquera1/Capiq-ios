import SwiftUI

struct MainMenuView: View {
    @Bindable var game: GameModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 20)
                .padding(.bottom, 24)

            gameLogList

            newGameButton
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .toolbar(.hidden)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("🇩🇴 🇨🇺 🇵🇷")
                .font(.title3)

            HStack(spacing: 12) {
                DominoTileView()
                DominoTileView()
            }

            Text("Dominó Doble Seis")
                .font(.title.weight(.heavy))

            Text("Primero en llegar a 200 gana")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Game Log

    @ViewBuilder
    private var gameLogList: some View {
        if game.gameLog.isEmpty {
            ContentUnavailableView(
                "Sin Juegos",
                systemImage: "rectangle.on.rectangle.slash",
                description: Text("Los juegos completados aparecerán aquí")
            )
            .frame(maxHeight: .infinity)
        } else {
            List {
                Section {
                    ForEach(game.gameLog) { result in
                        HStack {
                            Text("Juego \(result.gameNumber)")
                                .font(.headline)
                            Spacer()
                            Text("\(result.nosotros)")
                                .foregroundStyle(Color(red: 0.30, green: 0.79, blue: 0.94))
                                .fontWeight(result.winner == "nosotros" ? .bold : .regular)
                            Text("–")
                                .foregroundStyle(.secondary)
                            Text("\(result.ellos)")
                                .foregroundStyle(Color(red: 0.97, green: 0.15, blue: 0.52))
                                .fontWeight(result.winner == "ellos" ? .bold : .regular)
                        }
                        .font(.body.monospaced())
                    }
                } header: {
                    HStack {
                        Text("Juegos de la Noche")
                        Spacer()
                        Text("Nos: \(game.nosotrosWins) – Ellos: \(game.ellosWins)")
                            .font(.caption)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - New Game Button

    private var newGameButton: some View {
        Button {
            game.startNewGame()
        } label: {
            Label("Juego Nuevo", systemImage: "plus.circle.fill")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.glassProminent)
        .tint(Color(red: 0.95, green: 0.45, blue: 0.17))
    }
}

#Preview {
    NavigationStack {
        MainMenuView(game: GameModel())
    }
    .preferredColorScheme(.dark)
}
