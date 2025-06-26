import SwiftUI
import WatchKit
import WatchConnectivity

struct HabitView: View {
    @ObservedObject private var store = WatchDataStore.shared
    @AppStorage("habitStreak") private var habitStreak: Int = 0
    @State private var lastUpdateDate: Date = Date()

    var body: some View {
        VStack(spacing: 8) {
            if store.availableHabits.isEmpty {
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
                    ForEach(store.availableHabits, id: \.self) { habit in
                        Toggle(habit.name, isOn: Binding(
                            get: { store.habits[habit.name, default: false] },
                            set: { newValue in
                                store.habits[habit.name] = newValue
                                updateStreak()
                                sendHabitsToPhone()
                            }
                        ))
                        .padding(.vertical, 2)
                    }
                }
                .frame(maxHeight: .infinity)
                
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Streak: \(habitStreak)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 4)
                
                Button(action: {
                    // Reset all habits for today
                    for habit in store.availableHabits {
                        store.habits[habit.name] = false
                    }
                    habitStreak = 0
                    WKInterfaceDevice.current().play(.click)
                    sendHabitsToPhone()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Day")
                    }
                    .font(.caption)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 4)
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
        !store.availableHabits.isEmpty && store.availableHabits.allSatisfy { habit in
            store.habits[habit.name, default: false]
        }
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
