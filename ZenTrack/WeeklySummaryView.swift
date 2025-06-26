import SwiftUI

struct WeeklySummaryView: View {
    @ObservedObject var watchData = WatchDataManager.shared
    
    var summary: [DailyData] {
        watchData.last7DaysSummary
    }
    
    var averageMood: String {
        let moods = summary.flatMap { $0.moodEntries }
        guard !moods.isEmpty else { return "-" }
        let moodValues = moods.compactMap { mood -> Int? in
            switch mood {
            case "😊": return 5
            case "😐": return 4
            case "😔": return 3
            case "😠": return 2
            case "😴": return 1
            default: return nil
            }
        }
        guard !moodValues.isEmpty else { return "-" }
        let avg = Double(moodValues.reduce(0, +)) / Double(moodValues.count)
        switch avg {
        case 4.5...: return "😊"
        case 3.5..<4.5: return "😐"
        case 2.5..<3.5: return "😔"
        case 1.5..<2.5: return "😠"
        default: return "😴"
        }
    }
    
    var totalWater: Int {
        summary.reduce(0) { $0 + $1.water }
    }
    var totalFocus: Int {
        summary.reduce(0) { $0 + $1.focus }
    }
    var totalBreathe: Int {
        summary.reduce(0) { $0 + $1.breathe }
    }
    var averageWater: Int {
        summary.isEmpty ? 0 : totalWater / summary.count
    }
    var averageFocus: Int {
        summary.isEmpty ? 0 : totalFocus / summary.count
    }
    var averageBreathe: Int {
        summary.isEmpty ? 0 : totalBreathe / summary.count
    }
    var bestFocusDay: DailyData? {
        summary.max(by: { $0.focus < $1.focus })
    }
    var bestMoodDay: DailyData? {
        summary.max(by: { $0.moodCount < $1.moodCount })
    }
    var bestWaterDay: DailyData? {
        summary.max(by: { $0.water < $1.water })
    }
    var bestBreatheDay: DailyData? {
        summary.max(by: { $0.breathe < $1.breathe })
    }
    var habitCompletionRate: Double {
        let total = summary.flatMap { $0.habits.values }.count
        let completed = summary.flatMap { $0.habits.values }.filter { $0 }.count
        return total == 0 ? 0 : Double(completed) / Double(total)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Weekly Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    DataCardView(title: "Avg Mood", icon: "face.smiling", iconColor: .orange, content: averageMood, contentType: .emoji)
                    DataCardView(title: "Avg Water", icon: "drop.fill", iconColor: .blue, content: "\(averageWater) ml", contentType: .text)
                    DataCardView(title: "Avg Focus", icon: "brain.head.profile", iconColor: .green, content: "\(averageFocus) min", contentType: .text)
                    DataCardView(title: "Avg Breathe", icon: "wind", iconColor: .cyan, content: "\(averageBreathe)", contentType: .text)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Habit Completion Rate: \(Int(habitCompletionRate * 100))%")
                        .font(.headline)
                    if let best = bestFocusDay {
                        Text("Best Focus: \(best.focus) min on \(best.date)")
                            .font(.subheadline)
                    }
                    if let best = bestWaterDay {
                        Text("Best Water: \(best.water) ml on \(best.date)")
                            .font(.subheadline)
                    }
                    if let best = bestBreatheDay {
                        Text("Best Breathe: \(best.breathe) on \(best.date)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last 7 Days")
                        .font(.headline)
                    ForEach(summary, id: \.date) { day in
                        HStack {
                            Text(day.date)
                                .font(.subheadline)
                            Spacer()
                            Text("Mood: \(day.averageMood), Water: \(day.water)ml, Focus: \(day.focus)m, Breathe: \(day.breathe)")
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Weekly Summary")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}

struct WeeklySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklySummaryView()
    }
} 