import SwiftUI

struct TeamCardView: View {
    let name: String
    let score: Int
    let remaining: Int
    let accentColor: Color
    @Binding var input: String
    let gameOver: Bool
    let onAdd: () -> Void

    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(name.uppercased())
                    .font(.caption.weight(.heavy))
                    .tracking(2)
                    .foregroundStyle(accentColor)

                Spacer()

                Text("\(remaining) para ganar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if gameOver {
                Text("\(score)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(accentColor)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: score)
            } else {
                HStack(spacing: 16) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(accentColor)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: score)

                    TextField("0", text: $input)
                        .keyboardType(.numberPad)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(width: 110)
                        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
                        .focused($inputFocused)
                        .onSubmit { inputFocused = false; onAdd() }

                    Button {
                        inputFocused = false
                        onAdd()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(accentColor, in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}
