import Foundation
import WatchConnectivity

struct Habit: Codable, Hashable {
    var name: String
    var category: String
}

// Add this data store to keep the current state
class WatchDataStore: ObservableObject {
    static let shared = WatchDataStore()
    @Published var mood: String = ""
    @Published var water: Int = 0
    @Published var focus: Int = 0
    @Published var breathe: Int = 0
    @Published var habits: [String: Bool] = [:]
    @Published var availableHabits: [Habit] = []
    @Published var medicineReminders: [String] = []
}

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WCSession activated")
            print("Session reachable: \(session.isReachable)")
        } else {
            print("WCSession not supported")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activationDidCompleteWith state: \(activationState.rawValue), error: \(String(describing: error))")
    }
    
    // func sessionDidBecomeInactive(_ session: WCSession) {
    //     print("WCSession didBecomeInactive")
    // }
    
    // func sessionDidDeactivate(_ session: WCSession) {
    //     print("WCSession didDeactivate")
    //     session.activate()
    // }
    
    // Add message receiving functionality
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Watch received message: \(message)")
        
        if let messageType = message["type"] as? String {
            switch messageType {
            case "habits_update":
                handleHabitsUpdate(message: message)
            case "medicine_update":
                handleMedicineUpdate(message: message)
            default:
                print("Unknown message type: \(messageType)")
            }
        }
    }
    
    private func handleHabitsUpdate(message: [String: Any]) {
        if let availableHabitsData = message["availableHabits"] as? [[String: Any]] {
            let decoder = JSONDecoder()
            let habits: [Habit] = availableHabitsData.compactMap { dict in
                guard let name = dict["name"] as? String, let category = dict["category"] as? String else { return nil }
                return Habit(name: name, category: category)
            }
            DispatchQueue.main.async {
                WatchDataStore.shared.availableHabits = habits
            }
            print("Received available habits: \(habits)")
        }
        if let currentHabits = message["currentHabits"] as? [String: Bool] {
            DispatchQueue.main.async {
                WatchDataStore.shared.habits = currentHabits
            }
            print("Received current habits: \(currentHabits)")
        }
    }
    
    private func handleMedicineUpdate(message: [String: Any]) {
        if let medicineReminders = message["medicineReminders"] as? [String] {
            DispatchQueue.main.async {
                WatchDataStore.shared.medicineReminders = medicineReminders
            }
            print("Received medicine reminders: \(medicineReminders)")
        }
    }
    
    // Add this function to send data to the iOS app
    func sendDataToPhone(mood: String, water: Int, focus: Int, breathe: Int, habits: [String: Bool]) {
        let session = WCSession.default
        guard session.isReachable else {
            print("iPhone is not reachable")
            return
        }
        let message: [String: Any] = [
            "mood": mood,
            "water": water,
            "focus": focus,
            "breathe": breathe,
            "habits": habits
        ]
        print("Sending message to iPhone: \(message)")
        print("Focus value being sent: \(focus)")
        print("Breathe value being sent: \(breathe)")
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    // Update sendDataToPhone to use WatchDataStore.shared by default
    func sendCurrentStateToPhone() {
        let store = WatchDataStore.shared
        print("sendCurrentStateToPhone - store.focus: \(store.focus), store.breathe: \(store.breathe)")
        sendDataToPhone(mood: store.mood, water: store.water, focus: store.focus, breathe: store.breathe, habits: store.habits)
    }
    
    // Add this function to request medicine reminders from the phone
    func requestMedicineRemindersFromPhone() {
        let session = WCSession.default
        guard session.isReachable else {
            print("iPhone is not reachable for medicine request")
            return
        }
        let message: [String: Any] = ["type": "medicine_request"]
        print("Requesting medicine reminders from iPhone")
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error requesting medicine reminders: \(error.localizedDescription)")
        }
    }
    
    // Send medicine taken status to phone
    func sendMedicineTakenStatusToPhone(medicine: String, taken: Bool) {
        let session = WCSession.default
        guard session.isReachable else {
            print("iPhone is not reachable for medicine taken status")
            return
        }
        let today = Self.dateString(for: Date())
        let message: [String: Any] = [
            "type": "medicine_taken",
            "medicine": medicine,
            "taken": taken,
            "date": today
        ]
        print("Sending medicine taken status to iPhone: \(message)")
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending medicine taken status: \(error.localizedDescription)")
        }
    }
    
    static func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
