import SwiftUI
import WatchKit
import WatchConnectivity

struct MoodView: View {
    @ObservedObject private var store = WatchDataStore.shared
    @State private var confirmationMessage: String = ""
    @State private var showConfirmation: Bool = false

    let moods = ["😊", "😔", "😠", "😐", "😴"]

    var body: some View {
        VStack(spacing: 12) {
            Text("Select your mood")
                .font(.headline)
            HStack(spacing: 10) {
                ForEach(moods, id: \.self) { mood in
                    Button(action: {
                        store.mood = mood
                        confirmationMessage = "Mood logged: \(mood)"
                        showConfirmation = true
                        WKInterfaceDevice.current().play(.click)
                        WatchSessionManager.shared.sendCurrentStateToPhone()
                    }) {
                        Text(mood)
                            .font(.largeTitle)
                    }
                }
            }
            if showConfirmation {
                Text(confirmationMessage)
                    .font(.footnote)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
            Spacer()
            Button(action: {
                store.mood = ""
                confirmationMessage = "Mood reset"
                showConfirmation = true
                WKInterfaceDevice.current().play(.click)
                WatchSessionManager.shared.sendCurrentStateToPhone()
            }) {
                Text("Reset Day")
                    .font(.headline)
                    .padding()
                    .background(Color.red.opacity(0.3))
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Mood Tracker")
        .animation(.easeInOut, value: showConfirmation)
    }
}

struct MoodView_Previews: PreviewProvider {
    static var previews: some View {
        MoodView()
    }
}
