import SwiftUI

struct TrackView: View {
    @Bindable var model: AppModel
    @Bindable var auth: AuthModel

    var body: some View {
        ScreenScroll(title: "Track") {
            intakeWidget
            waterCard
            weightCard
            moodCard
        }
        .onAppear {
            model.refreshConsumptionEntries()
        }
    }

    private var intakeWidget: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Consumption log")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(NFTheme.text)
                        Text("Every item is saved with the time so daily eating and drinking patterns are easier to read.")
                            .font(.system(size: 12))
                            .foregroundStyle(NFTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(systemName: "clock.badge.plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(NFTheme.accent)
                }

                TextField("What did you consume?", text: $model.intakeName)
                    .font(.system(size: 15))
                    .foregroundStyle(NFTheme.text)
                    .padding(14)
                    .background(NFTheme.surfaceRaised)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ConsumptionCategory.allCases) { category in
                            IntakeCategoryChip(category: category, selected: model.intakeCategory == category) {
                                model.intakeCategory = category
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    TrackerButton(title: "Log item", prominent: true) {
                        model.addConsumption()
                        syncIfSignedIn()
                    }
                    Button {
                        model.logWaterGlass()
                        syncIfSignedIn()
                    } label: {
                        Label("Water", systemImage: "drop.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(NFTheme.text)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                DailyCategorySummary(model: model)

                VStack(spacing: 10) {
                    ForEach(model.entriesToday().prefix(4)) { entry in
                        IntakeEntryRow(entry: entry)
                    }
                }
            }
        }
    }

    private var waterCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Water")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(model.water) / 8 glasses")
                        .font(.system(size: 13))
                        .foregroundStyle(NFTheme.secondaryText)
                }

                HStack(spacing: 8) {
                    ForEach(0..<8, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(index < model.water ? NFTheme.accent : .clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(NFTheme.accent, lineWidth: 1.5)
                            )
                            .frame(width: 28, height: 36)
                    }
                }

                HStack(spacing: 10) {
                    TrackerButton(title: "-") { model.adjustWater(by: -1) }
                    TrackerButton(title: "+", prominent: true) {
                        model.logWaterGlass()
                        syncIfSignedIn()
                    }
                }
            }
        }
    }

    private var weightCard: some View {
        Card {
            VStack(spacing: 16) {
                HStack {
                    Text("Weight")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(model.displayWeight().oneDecimal) \(model.units.weightLabel)")
                        .font(.system(size: 20, weight: .black))
                }

                HStack(spacing: 10) {
                    TrackerButton(title: "- 0.1") {
                        model.adjustWeight(by: model.units == .metric ? -0.1 : -0.5 / 2.20462)
                    }
                    TrackerButton(title: "+ 0.1", prominent: true) {
                        model.adjustWeight(by: model.units == .metric ? 0.1 : 0.5 / 2.20462)
                    }
                }
            }
        }
    }

    private var moodCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Text("How do you feel?")
                    .font(.system(size: 15, weight: .semibold))
                HStack {
                    ForEach(Mood.allCases) { mood in
                        Button {
                            model.mood = mood
                        } label: {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(color(for: mood))
                                    .frame(width: 38, height: 38)
                                    .overlay(Circle().stroke(model.mood == mood ? NFTheme.accent : .clear, lineWidth: 3))
                                Text(mood.rawValue)
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(NFTheme.tertiaryText)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func color(for mood: Mood) -> Color {
        switch mood {
        case .great: Color(red: 0.93, green: 0.72, blue: 0.12)
        case .good: Color(red: 0.90, green: 0.66, blue: 0.08)
        case .okay: Color(red: 0.82, green: 0.58, blue: 0.06)
        case .low: Color(red: 0.66, green: 0.46, blue: 0.05)
        case .bad: Color(red: 0.48, green: 0.34, blue: 0.05)
        }
    }

    private func syncIfSignedIn() {
        guard auth.isSignedIn else { return }
        Task {
            await auth.sync(appModel: model)
        }
    }
}

private struct IntakeCategoryChip: View {
    let category: ConsumptionCategory
    let selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(category.rawValue, systemImage: category.symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selected ? .white : NFTheme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? AnyShapeStyle(NFTheme.gradient) : AnyShapeStyle(NFTheme.surfaceRaised))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct DailyCategorySummary: View {
    @Bindable var model: AppModel

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ConsumptionCategory.allCases) { category in
                VStack(spacing: 4) {
                    Image(systemName: category.symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(NFTheme.accent)
                    Text("\(model.countToday(for: category))")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(NFTheme.text)
                    Text(category.rawValue)
                        .font(.system(size: 9))
                        .foregroundStyle(NFTheme.tertiaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(NFTheme.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

private struct IntakeEntryRow: View {
    let entry: ConsumptionEntry

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: entry.category.symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(NFTheme.accent)
                .frame(width: 30, height: 30)
                .background(NFTheme.accent.opacity(0.14))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NFTheme.text)
                Text(entry.category.rawValue)
                    .font(.system(size: 11))
                    .foregroundStyle(NFTheme.tertiaryText)
            }
            Spacer()
            Text(entry.date.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(NFTheme.secondaryText)
        }
    }
}

private struct TrackerButton: View {
    let title: String
    var prominent = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(prominent ? NFTheme.accent : .white.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
