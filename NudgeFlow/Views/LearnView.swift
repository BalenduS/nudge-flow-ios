import SwiftUI

struct LearnView: View {
    private let categories = ["All", "Fasting 101", "Nutrition", "Mindset", "Science"]
    private let articles = [
        Article(title: "The Science of Autophagy", category: "Science", time: "6 min read"),
        Article(title: "A Beginner's Guide to 16:8", category: "Fasting 101", time: "4 min read"),
        Article(title: "What to Eat During Your Window", category: "Nutrition", time: "5 min read"),
        Article(title: "Breaking Through a Weight Plateau", category: "Mindset", time: "7 min read"),
        Article(title: "Electrolytes 101", category: "Nutrition", time: "3 min read"),
        Article(title: "How Fasting Affects Sleep", category: "Science", time: "5 min read")
    ]

    var body: some View {
        ScreenScroll(title: "Learn") {
            featuredBanner

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .font(.system(size: 13))
                            .foregroundStyle(NFTheme.secondaryText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(NFTheme.surface)
                            .clipShape(Capsule())
                    }
                }
            }

            VStack(spacing: 12) {
                ForEach(articles) { article in
                    HStack(spacing: 12) {
                        StripedThumbnail()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(article.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(NFTheme.text)
                            Text("\(article.category) · \(article.time)")
                                .font(.system(size: 12))
                                .foregroundStyle(NFTheme.tertiaryText)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private var featuredBanner: some View {
        ZStack(alignment: .bottomLeading) {
            StripedThumbnail()
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text("Featured")
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .foregroundStyle(NFTheme.accentTwo)
                Text("Why Your First Fast Feels Hard")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(NFTheme.text)
            }
            .padding(16)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct Article: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let time: String
}

private struct StripedThumbnail: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(NFTheme.surfaceRaised))
            for offset in stride(from: -size.height, through: size.width, by: 16) {
                var path = Path()
                path.move(to: CGPoint(x: offset, y: size.height))
                path.addLine(to: CGPoint(x: offset + size.height, y: 0))
                path.addLine(to: CGPoint(x: offset + size.height + 8, y: 0))
                path.addLine(to: CGPoint(x: offset + 8, y: size.height))
                path.closeSubpath()
                context.fill(path, with: .color(NFTheme.surface.opacity(0.6)))
            }
        }
    }
}
