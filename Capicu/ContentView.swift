import SwiftUI

struct ContentView: View {
    var body: some View {
        MainMenuView(game: GameModel())
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
