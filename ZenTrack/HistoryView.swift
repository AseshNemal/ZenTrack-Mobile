import SwiftUI

struct HistoryView: View {
    @ObservedObject var watchData = WatchDataManager.shared

    var body: some View {
        List {
            if watchData.history.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No History Yet")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    Text("Your daily data will appear here once you start tracking with your Apple Watch")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(watchData.history.keys.sorted(by: >), id: \.self) { date in
                    if let data = watchData.history[date] {
                        NavigationLink(destination: DailyDetailView(data: data)) {
                            HistoryRowView(data: data)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct HistoryRowView: View {
    let data: DailyData
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: data.date) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return data.date
    }
    
    var completedHabitsCount: Int {
        data.habits.values.filter { $0 }.count
    }
    
    var totalHabitsCount: Int {
        data.habits.count
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(formattedDate)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 16) {
                    if !data.averageMood.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "face.smiling")
                                .foregroundColor(.orange)
                            Text(data.averageMood)
                                .font(.subheadline)
                            if data.moodCount > 1 {
                                Text("(\(data.moodCount))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if data.water > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("\(data.water)ml")
                                .font(.subheadline)
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    if data.focus > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.green)
                            Text("\(data.focus)m")
                                .font(.subheadline)
                        }
                    }
                    
                    if data.breathe > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .foregroundColor(.cyan)
                            Text("\(data.breathe)")
                                .font(.subheadline)
                        }
                    }
                }
                
                if totalHabitsCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(completedHabitsCount)/\(totalHabitsCount) habits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

struct DailyDetailView: View {
    let data: DailyData

    var habitsString: String {
        data.habits.map { "\($0.key): \($0.value ? "Yes" : "No")" }.joined(separator: ", ")
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: data.date) {
            formatter.dateStyle = .full
            return formatter.string(from: date)
        }
        return data.date
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(formattedDate)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 8)
                
                // Mood Section
                if !data.averageMood.isEmpty {
                    VStack(spacing: 16) {
                        DataCardView(
                            title: "Average Mood",
                            icon: "face.smiling",
                            iconColor: .orange,
                            content: data.averageMood,
                            contentType: .emoji
                        )
                        
                        if data.moodCount > 1 {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    Text("All Mood Entries (\(data.moodCount))")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 60))
                                ], spacing: 12) {
                                    ForEach(data.moodEntries, id: \.self) { mood in
                                        Text(mood)
                                            .font(.title2)
                                            .padding(8)
                                            .background(Color.orange.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                
                // Water Section
                if data.water > 0 {
                    DataCardView(
                        title: "Water Intake",
                        icon: "drop.fill",
                        iconColor: .blue,
                        content: "\(data.water) ml",
                        contentType: .text
                    )
                }
                
                // Focus Section
                if data.focus > 0 {
                    DataCardView(
                        title: "Focus Time",
                        icon: "brain.head.profile",
                        iconColor: .green,
                        content: "\(data.focus) minutes",
                        contentType: .text
                    )
                }
                
                // Breathe Section
                if data.breathe > 0 {
                    DataCardView(
                        title: "Breathing Sessions",
                        icon: "wind",
                        iconColor: .cyan,
                        content: "\(data.breathe) sessions",
                        contentType: .text
                    )
                }
                
                // Habits Section
                if !data.habits.isEmpty {
                    HabitsCardView(habits: data.habits)
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Daily Summary")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
} 