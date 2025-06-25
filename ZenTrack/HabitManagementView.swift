import SwiftUI

struct HabitManagementView: View {
    @ObservedObject var watchData = WatchDataManager.shared
    @State private var newHabitName: String = ""
    @State private var showingAddHabit = false
    
    var body: some View {
        List {
            Section(header: Text("Today's Habits")) {
                ForEach(watchData.availableHabits, id: \.self) { habit in
                    HStack {
                        Toggle(habit, isOn: Binding(
                            get: { watchData.habits[habit] ?? false },
                            set: { _ in watchData.toggleHabit(habit) }
                        ))
                        
                        Spacer()
                        
                        Button(action: {
                            watchData.removeHabit(habit)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            Section(header: Text("Add New Habit")) {
                HStack {
                    TextField("Enter habit name", text: $newHabitName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        if !newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            watchData.addHabit(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines))
                            newHabitName = ""
                        }
                    }
                    .disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationTitle("Manage Habits")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct HabitManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabitManagementView()
        }
    }
} 