import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date())

        // Refresh every 15 min + force at midnight
        let calendar = Calendar.current
        let next15Min = calendar.date(byAdding: .minute, value: 15, to: Date())!
        let midnight = calendar.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime) ?? next15Min
        
        let nextRefresh = min(next15Min, midnight)
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
}

// MARK: - Widget View
struct CalendarWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetRenderingMode) var renderingMode   // iOS 17+
    @Environment(\.colorScheme) var colorScheme             // Works on iOS 16 too

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            // Smart background & text colors
            let isDark = colorScheme == .dark
            let backgroundColor = isDark ? Color(hex: "2E2E2E") : Color(hex: "FFFFFF")
            let textColor = isDark ? Color.white : Color(hex: "1C1C1E")
            let subtitleColor = isDark ? Color.white.opacity(0.8) : Color(hex: "3C3C43").opacity(0.6)

            VStack(spacing: 0) {
                Text(entry.date, format: .dateTime.weekday(.wide))
                    .font(.system(size: size * 0.14, weight: .light))
                    .foregroundColor(textColor)

                Text(entry.date, format: .dateTime.day())
                    .font(.system(size: size * 0.45, weight: .bold))
                    .foregroundColor(textColor)
                    .baselineOffset(-size * 0.02)

                Text(entry.date, format: .dateTime.year(.defaultDigits).month(.wide))
                    .font(.system(size: size * 0.12, weight: .medium))
                    .foregroundColor(subtitleColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
        }
        .widgetURL(URL(string: "flutterzenolok://open")!)
    }
}

// MARK: - Widget Definition (STATIC = No Configurable Intent)
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calendar Widget")
        .description("Beautiful current date")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Hex Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 255, (int >> 8) & 255, int & 255)
        case 8: (a, r, g, b) = ((int >> 24) & 255, (int >> 16) & 255, (int >> 8) & 255, int & 255)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
