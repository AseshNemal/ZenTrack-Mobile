import SwiftUI

struct DashboardView: View {
    @ObservedObject var watchData = WatchDataManager.shared
    
    var todayData: DailyData? {
        let today = WatchDataManager.dateString(for: Date())
        return watchData.history[today]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Connection Status Card
                    ConnectionStatusCard(isPaired: watchData.isPaired)
                    
                    // History Button
                    NavigationLink(destination: HistoryView()) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                            Text("View History")
                                .font(.headline)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Manage Habits Button
                    NavigationLink(destination: HabitManagementView()) {
                        HStack {
                            Image(systemName: "list.bullet.circle")
                                .font(.title2)
                            Text("Manage Habits")
                                .font(.headline)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Today's Data Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Mood Card
                        if !watchData.mood.isEmpty {
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
                                
                                Text(watchData.mood)
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
                        }
                        
                        // Water Card
                        if watchData.water > 0 {
                            DataCardView(
                                title: "Water",
                                icon: "drop.fill",
                                iconColor: .blue,
                                content: "\(watchData.water) ml",
                                contentType: .text
                            )
                        }
                        
                        // Focus Card
                        if watchData.focus > 0 {
                            DataCardView(
                                title: "Focus",
                                icon: "brain.head.profile",
                                iconColor: .green,
                                content: "\(watchData.focus) min",
                                contentType: .text
                            )
                        }
                        
                        // Breathe Card
                        if watchData.breathe > 0 {
                            DataCardView(
                                title: "Breathe",
                                icon: "wind",
                                iconColor: .cyan,
                                content: "\(watchData.breathe)",
                                contentType: .text
                            )
                        }
                    }
                    
                    // Habits Section
                    if !watchData.habits.isEmpty {
                        HabitsCardView(habits: watchData.habits)
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
    
    var completedHabits: [String] {
        habits.filter { $0.value }.map { $0.key }
    }
    
    var incompleteHabits: [String] {
        habits.filter { !$0.value }.map { $0.key }
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
                Text("\(completedHabits.count)/\(habits.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(completedHabits, id: \.self) { habit in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(habit)
                            .font(.body)
                        Spacer()
                    }
                }
                
                ForEach(incompleteHabits, id: \.self) { habit in
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                        Text(habit)
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
