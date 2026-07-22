import SwiftUI

struct LearnView: View {
    @State private var selectedCategory = "All"

    private let categories = ["All", "Fasting 101", "Nutrition", "Hydration", "Mindset", "Science"]
    private let articles = [
        Article(title: "Your First 16:8 Week", category: "Fasting 101", time: "5 min read", summary: "A simple rhythm for easing into fasting without overcorrecting.", symbol: "timer", tone: .amber),
        Article(title: "What Counts as Breaking a Fast?", category: "Fasting 101", time: "4 min read", summary: "Calories, sweeteners, milk, coffee, and the gray zones that matter.", symbol: "questionmark.circle.fill", tone: .olive),
        Article(title: "How to Open Your Eating Window", category: "Nutrition", time: "6 min read", summary: "Start with protein, fiber, and fluids before reaching for a heavy meal.", symbol: "fork.knife", tone: .orange),
        Article(title: "Electrolytes Without Overthinking", category: "Hydration", time: "3 min read", summary: "When plain water is enough and when sodium can help.", symbol: "drop.fill", tone: .blue),
        Article(title: "Coffee, Tea, and Fasting", category: "Hydration", time: "4 min read", summary: "How caffeine affects hunger, sleep, and your fasting window.", symbol: "mug.fill", tone: .brown),
        Article(title: "Understanding Hunger Waves", category: "Mindset", time: "5 min read", summary: "Most urges rise and fall. Learn how to ride them calmly.", symbol: "waveform.path.ecg", tone: .rose),
        Article(title: "Autophagy in Plain English", category: "Science", time: "7 min read", summary: "What the term means, what we know, and where claims get fuzzy.", symbol: "sparkles", tone: .gold),
        Article(title: "Fasting and Sleep Quality", category: "Science", time: "5 min read", summary: "Why late meals can disrupt rest and how to adjust gently.", symbol: "moon.zzz.fill", tone: .indigo),
        Article(title: "Reading Your Consumption Patterns", category: "Mindset", time: "6 min read", summary: "Use your logs to spot triggers, not to judge yourself.", symbol: "chart.xyaxis.line", tone: .green)
    ]

    private var filteredArticles: [Article] {
        selectedCategory == "All" ? articles : articles.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ZStack {
            learnBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    featuredBanner
                    categoryRail
                    continueReading
                    articleSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
        }
    }

    private var learnBackground: some View {
        ZStack {
            NFTheme.background.ignoresSafeArea()
            LinearGradient(
                colors: [NFTheme.accent.opacity(0.18), .clear],
                startPoint: .topLeading,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Learn")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(NFTheme.text)
                Text("Short reads for fasting, hydration, and patterns.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NFTheme.secondaryText)
            }
            Spacer()
            Image(systemName: "book.pages.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(NFTheme.accent)
                .frame(width: 48, height: 48)
                .background(NFTheme.surfaceRaised)
                .clipShape(Circle())
        }
    }

    private var featuredBanner: some View {
        ZStack(alignment: .bottomLeading) {
            EditorialArtwork(tone: .gold)
            LinearGradient(colors: [.clear, .black.opacity(0.88)], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 10) {
                Text("Featured")
                    .font(.system(size: 11, weight: .black))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(NFTheme.accentTwo)

                Text("Why Your First Fast Feels Hard")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(NFTheme.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text("Hunger often arrives in waves. The first week is about rhythm, hydration, and confidence.")
                    .font(.system(size: 13, weight: .medium))
                    .lineSpacing(3)
                    .foregroundStyle(NFTheme.secondaryText)

                HStack(spacing: 8) {
                    Label("4 min read", systemImage: "clock")
                    Label("Beginner", systemImage: "leaf.fill")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(NFTheme.text.opacity(0.76))
            }
            .padding(18)
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 24, y: 14)
    }

    private var categoryRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(selectedCategory == category ? .white : NFTheme.secondaryText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(selectedCategory == category ? AnyShapeStyle(NFTheme.gradient) : AnyShapeStyle(NFTheme.surface))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var continueReading: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: 0.64)
                    .stroke(NFTheme.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("64%")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(NFTheme.text)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 4) {
                Text("Continue reading")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(NFTheme.accent)
                Text("Autophagy in Plain English")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(NFTheme.text)
                Text("3 minutes left")
                    .font(.system(size: 12))
                    .foregroundStyle(NFTheme.tertiaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(NFTheme.tertiaryText)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [NFTheme.surfaceRaised, NFTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var articleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedCategory == "All" ? "Recommended for you" : selectedCategory)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(NFTheme.text)
                Spacer()
                Text("\(filteredArticles.count) reads")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(NFTheme.tertiaryText)
            }

            VStack(spacing: 12) {
                ForEach(filteredArticles) { article in
                    ArticleCard(article: article)
                }
            }
        }
    }
}

private struct ArticleCard: View {
    let article: Article

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            ZStack {
                EditorialArtwork(tone: article.tone)
                Image(systemName: article.symbol)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white.opacity(0.92))
            }
            .frame(width: 76, height: 86)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    Text(article.category)
                        .font(.system(size: 10, weight: .black))
                        .textCase(.uppercase)
                        .foregroundStyle(article.tone.color)
                    Text(article.time)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(NFTheme.tertiaryText)
                }

                Text(article.title)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(NFTheme.text)
                    .lineLimit(2)

                Text(article.summary)
                    .font(.system(size: 12.5, weight: .medium))
                    .lineSpacing(2)
                    .foregroundStyle(NFTheme.secondaryText)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(NFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct Article: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let time: String
    let summary: String
    let symbol: String
    let tone: ArticleTone
}

private enum ArticleTone {
    case amber
    case gold
    case orange
    case olive
    case blue
    case brown
    case rose
    case indigo
    case green

    var color: Color {
        switch self {
        case .amber: NFTheme.accent
        case .gold: NFTheme.accentTwo
        case .orange: Color(red: 0.95, green: 0.48, blue: 0.18)
        case .olive: Color(red: 0.62, green: 0.66, blue: 0.22)
        case .blue: Color(red: 0.32, green: 0.64, blue: 0.92)
        case .brown: Color(red: 0.72, green: 0.48, blue: 0.28)
        case .rose: Color(red: 0.92, green: 0.38, blue: 0.48)
        case .indigo: Color(red: 0.42, green: 0.48, blue: 0.88)
        case .green: Color(red: 0.30, green: 0.72, blue: 0.42)
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.92), color.opacity(0.34), NFTheme.surfaceRaised],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct EditorialArtwork: View {
    let tone: ArticleTone

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .linearGradient(
                Gradient(colors: [tone.color.opacity(0.9), NFTheme.surfaceRaised, NFTheme.background]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: size.width, y: size.height)
            ))

            for offset in stride(from: -size.height, through: size.width, by: 14) {
                var path = Path()
                path.move(to: CGPoint(x: offset, y: size.height))
                path.addLine(to: CGPoint(x: offset + size.height, y: 0))
                path.addLine(to: CGPoint(x: offset + size.height + 7, y: 0))
                path.addLine(to: CGPoint(x: offset + 7, y: size.height))
                path.closeSubpath()
                context.fill(path, with: .color(.white.opacity(0.045)))
            }

            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.62, y: -size.height * 0.16, width: size.width * 0.56, height: size.width * 0.56)),
                with: .color(.white.opacity(0.12))
            )
        }
    }
}
