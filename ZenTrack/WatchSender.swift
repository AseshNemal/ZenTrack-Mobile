import Foundation
import WatchConnectivity

class WatchSender: NSObject, WCSessionDelegate {
    static let shared = WatchSender()
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
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
    
    func sendData(mood: String, water: Int, focus: Int, breathe: Int, habits: [String: Bool]) {
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
        
        print("Sending message: \(message)")
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}
