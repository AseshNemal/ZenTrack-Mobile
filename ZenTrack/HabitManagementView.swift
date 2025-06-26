import SwiftUI

struct HabitManagementView: View {
    @ObservedObject var watchData = WatchDataManager.shared
    @State private var newHabitName: String = ""
    @State private var newHabitCategory: String = "Health"
    @State private var newMedicineName: String = ""
    
    var habitsByCategory: [String: [Habit]] {
        Dictionary(grouping: watchData.availableHabits, by: { $0.category })
    }
    
    var body: some View {
        List {
            Section(header: Text("Today's Habits")) {
                ForEach(watchData.availableCategories, id: \.self) { category in
                    if let habits = habitsByCategory[category], !habits.isEmpty {
                        Text(category)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        ForEach(habits, id: \.self) { habit in
                            HStack {
                                Toggle(habit.name, isOn: Binding(
                                    get: { watchData.habits[habit.name] ?? false },
                                    set: { _ in watchData.toggleHabit(habit.name) }
                                ))
                                Spacer()
                                Button(action: {
                                    watchData.removeHabit(habit.name)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Add New Habit")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Enter habit name", text: $newHabitName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Picker("Category", selection: $newHabitCategory) {
                            ForEach(watchData.availableCategories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        Button("Add") {
                            if !newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                watchData.addHabit(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines), category: newHabitCategory)
                                newHabitName = ""
                            }
                        }
                        .disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            
            Section(header: Text("Medicine Reminders")) {
                ForEach(watchData.medicineReminders, id: \.self) { med in
                    HStack {
                        Text(med)
                        Spacer()
                        Button(action: {
                            watchData.removeMedicineReminder(med)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                HStack {
                    TextField("Add medicine", text: $newMedicineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !newMedicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            watchData.addMedicineReminder(newMedicineName.trimmingCharacters(in: .whitespacesAndNewlines))
                            newMedicineName = ""
                        }
                    }
                    .disabled(newMedicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationTitle("Manage Habits & Reminders")
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