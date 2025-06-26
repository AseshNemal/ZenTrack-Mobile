import SwiftUI

struct DashboardView: View {
    @ObservedObject var watchData = WatchDataManager.shared
    
    var todayData: DailyData? {
        let today = WatchDataManager.dateString(for: Date())
        let data = watchData.history[today]
        print("Dashboard todayData - focus: \(data?.focus ?? 0), breathe: \(data?.breathe ?? 0)")
        return data
    }
    
    var todayMedicineTakenStatus: [String: Bool] {
        watchData.medicineTakenStatus[WatchDataManager.dateString(for: Date())] ?? [:]
    }
    
    var todayString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Connection Status Card
                    ConnectionStatusCard(isPaired: watchData.isPaired)
                    
                    // Today's Data Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Mood Card
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "face.smiling")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                Spacer()
                                if let todayData = todayData, todayData.moodCount > 1 {
                                    Text("(\(todayData.moodCount))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text(todayData?.averageMood.isEmpty == false ? todayData!.averageMood : "-")
                                .font(.system(size: 32))
                            Text("Average Mood")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // Water Card
                        DataCardView(
                            title: "Water",
                            icon: "drop.fill",
                            iconColor: .blue,
                            content: todayData != nil && todayData!.water > 0 ? "\(todayData!.water) ml" : "0 ml",
                            contentType: .text
                        )
                        
                        // Focus Card
                        DataCardView(
                            title: "Focus",
                            icon: "brain.head.profile",
                            iconColor: .green,
                            content: todayData != nil && todayData!.focus > 0 ? "\(todayData!.focus) min" : "0 min",
                            contentType: .text
                        )
                        
                        // Breathe Card
                        DataCardView(
                            title: "Breathe",
                            icon: "wind",
                            iconColor: .cyan,
                            content: todayData != nil && todayData!.breathe > 0 ? "\(todayData!.breathe)" : "0",
                            contentType: .text
                        )
                    }
                    
                    // Habits Section
                    if let habits = todayData?.habits, !habits.isEmpty {
                        HabitsCardView(habits: habits)
                    } else {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text("Today's Habits")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            Text("No habits tracked yet today.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }

                    // Medicine Section
                    if !watchData.medicineReminders.isEmpty {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "pills")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("Today's Medicine")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            MedicineStatusList(
                                medicines: watchData.medicineReminders,
                                takenStatus: todayMedicineTakenStatus
                            )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("ZenTrack")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ConnectionStatusCard: View {
    let isPaired: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isPaired ? "applewatch" : "applewatch.slash")
                .font(.title2)
                .foregroundColor(isPaired ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isPaired ? "Watch Connected" : "Watch Not Connected")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(isPaired ? .green : .red)
                
                Text(isPaired ? "Data sync active" : "Connect your Apple Watch")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isPaired {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DataCardView: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: String
    let contentType: ContentType
    
    enum ContentType {
        case text, emoji
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                Spacer()
            }
            
            if contentType == .emoji {
                Text(content)
                    .font(.system(size: 32))
            } else {
                Text(content)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct HabitsCardView: View {
    let habits: [String: Bool]
    @ObservedObject private var watchData = WatchDataManager.shared
    
    var habitsByCategory: [String: [Habit]] {
        Dictionary(grouping: watchData.availableHabits, by: { $0.category })
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Today's Habits")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                let completed = habits.filter { $0.value }.count
                Text("\(completed)/\(habits.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ForEach(watchData.availableCategories, id: \.self) { category in
                if let habitsInCategory = habitsByCategory[category], !habitsInCategory.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        ForEach(habitsInCategory, id: \.self) { habit in
                            HStack {
                                let done = habits[habit.name] ?? false
                                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(done ? .green : .gray)
                                Text(habit.name)
                                    .font(.body)
                                    .foregroundColor(done ? .primary : .secondary)
                                if let streak = watchData.habitStreaks[habit.name], streak > 0 {
                                    Text("🔥 \(streak)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct MedicineStatusList: View {
    let medicines: [String]
    let takenStatus: [String: Bool]
    var body: some View {
        ForEach(medicines, id: \.self) { med in
            let taken = takenStatus[med] ?? false
            HStack {
                Image(systemName: taken ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(taken ? .green : .gray)
                Text(med)
                    .font(.body)
                Spacer()
                if taken {
                    Text("Taken")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Not taken")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
