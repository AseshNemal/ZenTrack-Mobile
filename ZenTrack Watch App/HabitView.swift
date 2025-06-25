import SwiftUI
import WatchKit
import WatchConnectivity

struct HabitView: View {
    @ObservedObject private var store = WatchDataStore.shared
    @AppStorage("habitStreak") private var habitStreak: Int = 0
    @State private var lastUpdateDate: Date = Date()

    var body: some View {
        VStack {
            if store.habits.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "list.bullet.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No Habits Set")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Add habits from your iPhone to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(store.habits.keys), id: \.self) { habit in
                        Toggle(habit, isOn: Binding(
                            get: { store.habits[habit, default: false] },
                            set: { newValue in
                                store.habits[habit] = newValue
                                updateStreak()
                                sendHabitsToPhone()
                            }
                        ))
                    }
                }
                
                Text("Streak: \(habitStreak) days")
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    // Reset all habits for today
                    for key in store.habits.keys {
                        store.habits[key] = false
                    }
                    habitStreak = 0
                    WKInterfaceDevice.current().play(.click)
                    sendHabitsToPhone()
                }) {
                    Text("Reset Day")
                        .font(.headline)
                        .padding()
                        .background(Color.red.opacity(0.3))
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Habit Tracker")
        .onAppear {
            updateStreak()
        }
    }

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = Calendar.current.startOfDay(for: lastUpdateDate)

        if today > lastDate {
            if allHabitsCompleted() {
                habitStreak += 1
            } else {
                habitStreak = 0
            }
            lastUpdateDate = Date()
        }
    }

    func allHabitsCompleted() -> Bool {
        !store.habits.isEmpty && store.habits.values.allSatisfy { $0 }
    }

    func sendHabitsToPhone() {
        WatchSessionManager.shared.sendCurrentStateToPhone()
    }
}

struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        HabitView()
    }
}
