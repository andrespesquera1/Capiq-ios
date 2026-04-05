import SwiftUI

struct TeamCardView: View {
    let name: String
    let score: Int
    let remaining: Int
    let accentColor: Color
    @Binding var input: String
    let gameOver: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(name.uppercased())
                .font(.subheadline.weight(.heavy))
                .tracking(2)
                .foregroundStyle(accentColor)

            Text("\(score)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(accentColor)
                .contentTransition(.numericText())
                .animation(.snappy, value: score)

            Divider()

            Text("\(remaining) para ganar")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if !gameOver {
                HStack(spacing: 10) {
                    TextField("Puntos", text: $input)
                        .keyboardType(.numberPad)
                        .font(.body.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
                        .onSubmit { onAdd() }

                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 40, height: 40)
                            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}
