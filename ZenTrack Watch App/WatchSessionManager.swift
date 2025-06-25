import Foundation
import WatchConnectivity

// Add this data store to keep the current state
class WatchDataStore: ObservableObject {
    static let shared = WatchDataStore()
    @Published var mood: String = ""
    @Published var water: Int = 0
    @Published var focus: Int = 0
    @Published var breathe: Int = 0
    @Published var habits: [String: Bool] = [:]
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
            default:
                print("Unknown message type: \(messageType)")
            }
        }
    }
    
    private func handleHabitsUpdate(message: [String: Any]) {
        if let availableHabits = message["availableHabits"] as? [String] {
            // Update the store with new available habits
            // Note: We'll need to update the HabitView to use these
            print("Received available habits: \(availableHabits)")
        }
        
        if let currentHabits = message["currentHabits"] as? [String: Bool] {
            // Update the store with current habit states
            WatchDataStore.shared.habits = currentHabits
            print("Received current habits: \(currentHabits)")
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
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    // Update sendDataToPhone to use WatchDataStore.shared by default
    func sendCurrentStateToPhone() {
        let store = WatchDataStore.shared
        sendDataToPhone(mood: store.mood, water: store.water, focus: store.focus, breathe: store.breathe, habits: store.habits)
    }
}
