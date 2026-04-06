import SwiftUI

@main
struct CapicuApp: App {
    @State private var game = GameModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainMenuView(game: game)
                    .navigationDestination(isPresented: $game.gameActive) {
                        GameView(game: game)
                    }
            }
            .preferredColorScheme(.dark)
        }
    }
}
