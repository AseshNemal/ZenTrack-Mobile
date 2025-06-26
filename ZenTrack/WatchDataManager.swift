import Foundation
import WatchConnectivity
import Combine

struct DailyData: Codable {
    var date: String
    var moodEntries: [String] // Array of mood entries for the day
    var water: Int
    var focus: Int
    var breathe: Int
    var habits: [String: Bool]
    
    // Computed property to get the most recent mood
    var mood: String {
        return moodEntries.last ?? ""
    }
    
    // Computed property to get average mood
    var averageMood: String {
        guard !moodEntries.isEmpty else { return "" }
        
        // Convert emojis to numerical values for averaging
        let moodValues = moodEntries.compactMap { emoji -> Int? in
            switch emoji {
            case "😊": return 5 // Very happy
            case "😐": return 4 // Neutral
            case "😔": return 3 // Sad
            case "😠": return 2 // Angry
            case "😴": return 1 // Tired
            default: return nil
            }
        }
        
        guard !moodValues.isEmpty else { return moodEntries.last ?? "" }
        
        let average = Double(moodValues.reduce(0, +)) / Double(moodValues.count)
        
        // Convert back to emoji based on average
        switch average {
        case 4.5...: return "😊"
        case 3.5..<4.5: return "😐"
        case 2.5..<3.5: return "😔"
        case 1.5..<2.5: return "😠"
        default: return "😴"
        }
    }
    
    // Computed property to get mood count
    var moodCount: Int {
        return moodEntries.count
    }
}

struct Habit: Codable, Hashable {
    var name: String
    var category: String
}

class WatchDataManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchDataManager()
    
    @Published var mood: String = ""
    @Published var water: Int = 0
    @Published var focus: Int = 0
    @Published var breathe: Int = 0
    @Published var habits: [String: Bool] = [:]
    @Published var isPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var isReachable: Bool = false
    @Published var history: [String: DailyData] = [:] // date string -> data
    @Published var availableCategories: [String] = ["Health", "Work", "Personal"]
    @Published var availableHabits: [Habit] = [
        Habit(name: "Drink Tea", category: "Health"),
        Habit(name: "Stretch", category: "Health"),
        Habit(name: "Smile", category: "Personal"),
        Habit(name: "No Sugar", category: "Health"),
        Habit(name: "Gratitude", category: "Personal")
    ]
    @Published var medicineReminders: [String] = []
    @Published var medicineTakenStatus: [String: [String: Bool]] = [:] // [date: [medicine: Bool]]
    @Published var habitStreaks: [String: Int] = [:] // [habitName: streakCount]
    
    private override init() {
        super.init()
        loadHistory()
        loadAvailableHabits()
        loadMedicineReminders()
        loadMedicineTakenStatus()
        loadHabitStreaks()
        activateSession()
    }
    
    private func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            DispatchQueue.main.async {
                self.isPaired = session.isPaired
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
        }
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Received message with replyHandler: \(message)")
        if let type = message["type"] as? String, type == "medicine_taken_status_request" {
            let date = message["date"] as? String ?? Self.dateString(for: Date())
            let status = self.medicineTakenStatus[date] ?? [:]
            replyHandler(["medicineTakenStatus": status])
            return
        }
        // Fallback to non-replyHandler version
        self.session(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
        DispatchQueue.main.async {
            if let type = message["type"] as? String {
                if type == "medicine_request" {
                    self.sendMedicineRemindersToWatch()
                    return
                } else if type == "medicine_taken" {
                    if let medicine = message["medicine"] as? String,
                       let taken = message["taken"] as? Bool,
                       let date = message["date"] as? String {
                        var dayStatus = self.medicineTakenStatus[date] ?? [:]
                        dayStatus[medicine] = taken
                        self.medicineTakenStatus[date] = dayStatus
                        self.saveMedicineTakenStatus()
                    }
                    return
                }
            }
            let today = Self.dateString(for: Date())
            
            // Get existing data for today or create new
            var dailyData = self.history[today] ?? DailyData(
                date: today,
                moodEntries: [],
                water: 0,
                focus: 0,
                breathe: 0,
                habits: [:]
            )
            
            // Handle mood - append to entries if provided
            if let newMood = message["mood"] as? String, !newMood.isEmpty {
                dailyData.moodEntries.append(newMood)
                print("Updated mood: \(newMood)")
            }
            
            // Handle other data - update if provided
            if let water = message["water"] as? Int {
                dailyData.water = water
                print("Updated water: \(water)")
            }
            if let focus = message["focus"] as? Int {
                dailyData.focus = focus
                print("Updated focus: \(focus)")
            }
            if let breathe = message["breathe"] as? Int {
                dailyData.breathe = breathe
                print("Updated breathe: \(breathe)")
            }
            if let habits = message["habits"] as? [String: Bool] {
                dailyData.habits = habits
                print("Updated habits: \(habits)")
            }
            
            // Save updated data
            self.history[today] = dailyData
            self.saveHistory()
            
            // Update streaks
            self.updateHabitStreaks()
            
            // Update current display values
            self.mood = dailyData.averageMood
            self.water = dailyData.water
            self.focus = dailyData.focus
            self.breathe = dailyData.breathe
            self.habits = dailyData.habits
            
            print("Final daily data - focus: \(dailyData.focus), breathe: \(dailyData.breathe)")
        }
    }

    static func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: "history")
        }
    }

    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "history"),
           let loaded = try? JSONDecoder().decode([String: DailyData].self, from: data) {
            history = loaded
            
            // Set current display values from today's data
            let today = Self.dateString(for: Date())
            if let todayData = history[today] {
                DispatchQueue.main.async {
                    self.mood = todayData.averageMood
                    self.water = todayData.water
                    self.focus = todayData.focus
                    self.breathe = todayData.breathe
                    self.habits = todayData.habits
                }
            }
        }
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habitName: String, category: String) {
        guard !availableHabits.contains(where: { $0.name == habitName }) else { return }
        let habit = Habit(name: habitName, category: category)
        availableHabits.append(habit)
        saveAvailableHabits()
        sendHabitsToWatch()
    }
    
    func removeHabit(_ habitName: String) {
        availableHabits.removeAll { $0.name == habitName }
        habits.removeValue(forKey: habitName)
        saveAvailableHabits()
        sendHabitsToWatch()
    }
    
    func toggleHabit(_ habitName: String) {
        habits[habitName] = !(habits[habitName] ?? false)
        saveHistory()
        updateHabitStreaks()
        sendHabitsToWatch()
    }
    
    private func sendHabitsToWatch() {
        let session = WCSession.default
        guard session.isReachable else {
            print("Watch is not reachable")
            return
        }
        let habitsArray = availableHabits.map { ["name": $0.name, "category": $0.category] }
        let message: [String: Any] = [
            "type": "habits_update",
            "availableHabits": habitsArray,
            "currentHabits": habits
        ]
        print("Sending habits update to watch: \(message)")
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending habits to watch: \(error.localizedDescription)")
        }
    }
    
    private func saveAvailableHabits() {
        if let data = try? JSONEncoder().encode(availableHabits) {
            UserDefaults.standard.set(data, forKey: "availableHabits")
        }
    }
    
    private func loadAvailableHabits() {
        if let data = UserDefaults.standard.data(forKey: "availableHabits"),
           let loaded = try? JSONDecoder().decode([Habit].self, from: data) {
            availableHabits = loaded
        }
    }
    
    // MARK: - Medicine Reminder Management
    func addMedicineReminder(_ reminder: String) {
        guard !medicineReminders.contains(reminder) else { return }
        medicineReminders.append(reminder)
        saveMedicineReminders()
        sendMedicineRemindersToWatch()
    }
    
    func removeMedicineReminder(_ reminder: String) {
        medicineReminders.removeAll { $0 == reminder }
        saveMedicineReminders()
        sendMedicineRemindersToWatch()
    }
    
    private func sendMedicineRemindersToWatch() {
        let session = WCSession.default
        guard session.isReachable else {
            print("Watch is not reachable")
            return
        }
        let message: [String: Any] = [
            "type": "medicine_update",
            "medicineReminders": medicineReminders
        ]
        print("Sending medicine reminders to watch: \(message)")
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending medicine reminders to watch: \(error.localizedDescription)")
        }
    }
    
    private func saveMedicineReminders() {
        if let data = try? JSONEncoder().encode(medicineReminders) {
            UserDefaults.standard.set(data, forKey: "medicineReminders")
        }
    }
    
    private func loadMedicineReminders() {
        if let data = UserDefaults.standard.data(forKey: "medicineReminders"),
           let loaded = try? JSONDecoder().decode([String].self, from: data) {
            medicineReminders = loaded
        }
    }
    
    // MARK: - Medicine Taken Status Persistence
    private func saveMedicineTakenStatus() {
        if let data = try? JSONEncoder().encode(medicineTakenStatus) {
            UserDefaults.standard.set(data, forKey: "medicineTakenStatus")
        }
    }
    private func loadMedicineTakenStatus() {
        if let data = UserDefaults.standard.data(forKey: "medicineTakenStatus"),
           let loaded = try? JSONDecoder().decode([String: [String: Bool]].self, from: data) {
            medicineTakenStatus = loaded
        }
    }
    
    func saveHabitStreaks() {
        if let data = try? JSONEncoder().encode(habitStreaks) {
            UserDefaults.standard.set(data, forKey: "habitStreaks")
        }
    }
    func loadHabitStreaks() {
        if let data = UserDefaults.standard.data(forKey: "habitStreaks"),
           let loaded = try? JSONDecoder().decode([String: Int].self, from: data) {
            habitStreaks = loaded
        }
    }
    
    // Call this after updating today's habits
    func updateHabitStreaks() {
        let today = Self.dateString(for: Date())
        guard let todayData = history[today] else { return }
        let yesterday = Self.dateString(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        let yesterdayData = history[yesterday]
        for habit in availableHabits {
            let doneToday = todayData.habits[habit.name] ?? false
            let doneYesterday = yesterdayData?.habits[habit.name] ?? false
            if doneToday {
                if doneYesterday {
                    habitStreaks[habit.name] = (habitStreaks[habit.name] ?? 0) + 1
                } else {
                    habitStreaks[habit.name] = 1
                }
            } else {
                habitStreaks[habit.name] = 0
            }
        }
        saveHabitStreaks()
    }

    // Returns the last 7 days of DailyData, newest first
    var last7DaysSummary: [DailyData] {
        let sortedDates = history.keys.sorted(by: >)
        let last7 = sortedDates.prefix(7)
        return last7.compactMap { history[$0] }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
