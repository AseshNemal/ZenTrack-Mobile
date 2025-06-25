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

class WatchDataManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchDataManager()
    
    @Published var mood: String = ""
    @Published var water: Int = 0
    @Published var focus: Int = 0
    @Published var breathe: Int = 0
    @Published var habits: [String: Bool] = [:]
    @Published var isPaired: Bool = false
    @Published var history: [String: DailyData] = [:] // date string -> data
    @Published var availableHabits: [String] = ["Drink Tea", "Stretch", "Smile", "No Sugar", "Gratitude"] // Default habits
    
    private override init() {
        super.init()
        loadHistory()
        loadAvailableHabits()
        activateSession()
    }
    
    private func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WCSession activated")
            print("Session reachable: \(session.isReachable)")
            print("Session paired: \(session.isPaired)")
            DispatchQueue.main.async {
                self.isPaired = session.isPaired
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session inactive if needed
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation if needed
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
        DispatchQueue.main.async {
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
            }
            
            // Handle other data - update if provided
            if let water = message["water"] as? Int {
                dailyData.water = water
            }
            if let focus = message["focus"] as? Int {
                dailyData.focus = focus
            }
            if let breathe = message["breathe"] as? Int {
                dailyData.breathe = breathe
            }
            if let habits = message["habits"] as? [String: Bool] {
                dailyData.habits = habits
            }
            
            // Save updated data
            self.history[today] = dailyData
            self.saveHistory()
            
            // Update current display values
            self.mood = dailyData.averageMood
            self.water = dailyData.water
            self.focus = dailyData.focus
            self.breathe = dailyData.breathe
            self.habits = dailyData.habits
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
        }
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habit: String) {
        guard !availableHabits.contains(habit) else { return }
        availableHabits.append(habit)
        saveAvailableHabits()
        sendHabitsToWatch()
    }
    
    func removeHabit(_ habit: String) {
        availableHabits.removeAll { $0 == habit }
        // Remove from current habits if it exists
        habits.removeValue(forKey: habit)
        saveAvailableHabits()
        sendHabitsToWatch()
    }
    
    func toggleHabit(_ habit: String) {
        habits[habit] = !(habits[habit] ?? false)
        saveHistory()
        sendHabitsToWatch()
    }
    
    private func sendHabitsToWatch() {
        let session = WCSession.default
        guard session.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        let message: [String: Any] = [
            "type": "habits_update",
            "availableHabits": availableHabits,
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
           let loaded = try? JSONDecoder().decode([String].self, from: data) {
            availableHabits = loaded
        }
    }
}
