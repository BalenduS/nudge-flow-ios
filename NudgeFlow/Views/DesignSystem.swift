import SwiftUI

enum NFTheme {
    static let background = Color(red: 0.043, green: 0.039, blue: 0.063)
    static let surface = Color(red: 0.102, green: 0.094, blue: 0.133)
    static let surfaceRaised = Color(red: 0.133, green: 0.122, blue: 0.173)
    static let text = Color(red: 0.961, green: 0.953, blue: 0.973)
    static let secondaryText = text.opacity(0.62)
    static let tertiaryText = text.opacity(0.42)
    static let accent = Color(red: 0.9092, green: 0.6349, blue: 0.0)
    static let accentTwo = Color(red: 0.8887, green: 0.7616, blue: 0.2331)
    static let destructive = Color(red: 0.95, green: 0.29, blue: 0.22)

    static let gradient = LinearGradient(
        colors: [accent, accentTwo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct GradientButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(NFTheme.gradient)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct AppMark: View {
    var size: CGFloat = 84

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(NFTheme.gradient)
                .shadow(color: NFTheme.accent.opacity(0.35), radius: size * 0.22, y: size * 0.12)

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(.white, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                .frame(width: size * 0.56, height: size * 0.56)
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(.white)
                .frame(width: size * 0.095, height: size * 0.095)
                .offset(x: -size * 0.26)
        }
        .frame(width: size, height: size)
    }
}

struct Card<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(NFTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct SelectRow: View {
    let title: String
    var subtitle: String?
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(NFTheme.tertiaryText)
                    }
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(NFTheme.accentTwo)
                }
            }
            .foregroundStyle(NFTheme.text)
            .padding(18)
            .background(selected ? NFTheme.accent.opacity(0.2) : .white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? NFTheme.accent.opacity(0.65) : .clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct StepperRow: View {
    let title: String
    let value: String
    var decrement: () -> Void
    var increment: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            HStack(spacing: 18) {
                RoundControl(systemName: "minus", action: decrement)
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .monospacedDigit()
                    .frame(minWidth: 78)
                RoundControl(systemName: "plus", action: increment)
            }
        }
    }
}

struct RoundControl: View {
    let systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(NFTheme.text)
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

extension Double {
    var oneDecimal: String {
        String(format: "%.1f", self)
    }
}
