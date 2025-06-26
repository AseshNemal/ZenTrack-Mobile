import SwiftUI
import WatchConnectivity

struct MedicineView: View {
    @ObservedObject private var store = WatchDataStore.shared
    @State private var takenStatus: [String: Bool] = [:]
    
    var body: some View {
        VStack {
            if store.medicineReminders.isEmpty {
                Spacer()
                Image(systemName: "pills")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                Text("No Medicine Reminders")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Add medicine reminders from your iPhone settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            } else {
                List {
                    ForEach(store.medicineReminders, id: \.self) { med in
                        Toggle(isOn: Binding(
                            get: { takenStatus[med, default: false] },
                            set: { newValue in
                                takenStatus[med] = newValue
                                WatchSessionManager.shared.sendMedicineTakenStatusToPhone(medicine: med, taken: newValue)
                            }
                        )) {
                            HStack {
                                Image(systemName: "pills")
                                    .foregroundColor(.blue)
                                Text(med)
                                    .font(.body)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Medicine")
        .onAppear {
            WatchSessionManager.shared.requestMedicineRemindersFromPhone()
            WatchSessionManager.shared.requestMedicineTakenStatusFromPhone { status in
                takenStatus = status
            }
        }
    }
}

// Extend WatchSessionManager to request today's taken status and handle reply
extension WatchSessionManager {
    func requestMedicineTakenStatusFromPhone(completion: @escaping ([String: Bool]) -> Void) {
        let session = WCSession.default
        guard session.isReachable else {
            print("iPhone is not reachable for medicine taken status request")
            completion([:])
            return
        }
        let today = Self.dateString(for: Date())
        let message: [String: Any] = ["type": "medicine_taken_status_request", "date": today]
        print("Requesting medicine taken status from iPhone")
        session.sendMessage(message, replyHandler: { reply in
            if let status = reply["medicineTakenStatus"] as? [String: Bool] {
                DispatchQueue.main.async {
                    completion(status)
                }
            } else {
                DispatchQueue.main.async {
                    completion([:])
                }
            }
        }, errorHandler: { error in
            print("Error requesting medicine taken status: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion([:])
            }
        })
    }
}

struct MedicineView_Previews: PreviewProvider {
    static var previews: some View {
        MedicineView()
    }
} 