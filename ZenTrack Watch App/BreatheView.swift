import SwiftUI
import WatchKit
import WatchConnectivity

struct BreatheView: View {
    @State private var isInhale = true
    @State private var timerCount = 0
    @State private var sessionRunning = false
    @State private var timer: Timer? = nil
    private let sessionDuration = 60 // seconds
    private let breathDuration = 4 // seconds
    @ObservedObject private var store = WatchDataStore.shared

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(isInhale ? Color.blue.opacity(0.5) : Color.green.opacity(0.5))
                    .frame(width: isInhale ? 150 : 100, height: isInhale ? 150 : 100)
                    .animation(.easeInOut(duration: Double(breathDuration)), value: isInhale)
                Text(isInhale ? "Inhale" : "Exhale")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
            Text("Time: \(timerCount)s")
                .font(.headline)

            Button(action: {
                if !sessionRunning {
                    startSession()
                }
            }) {
                Text(sessionRunning ? "Running..." : "Start")
                    .font(.headline)
                    .padding()
                    .background(sessionRunning ? Color.gray.opacity(0.3) : Color.blue.opacity(0.7))
                    .cornerRadius(10)
            }
            .disabled(sessionRunning)
            
            if sessionRunning || timerCount > 0 {
                Button(action: {
                    resetSession()
                }) {
                    Text("Reset")
                        .font(.headline)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Breathe")
        .onDisappear {
            // Send current progress when leaving the view
            if sessionRunning || timerCount > 0 {
                let completedBreaths = timerCount / breathDuration
                if completedBreaths > 0 {
                    store.breathe = completedBreaths
                    print("Breathe view disappeared - sending partial breathe progress: \(completedBreaths)")
                    WatchSessionManager.shared.sendCurrentStateToPhone()
                }
            }
        }
    }

    func startSession() {
        sessionRunning = true
        timerCount = 0
        isInhale = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerCount += 1
            if timerCount % breathDuration == 0 {
                isInhale.toggle()
                WKInterfaceDevice.current().play(.click)
            }
            if timerCount >= sessionDuration {
                timer?.invalidate()
                timer = nil
                sessionRunning = false
                WKInterfaceDevice.current().play(.notification)
                // Send breathe data to iPhone
                let completedBreaths = timerCount / breathDuration
                store.breathe = completedBreaths
                print("Breathe session completed - setting breathe to: \(completedBreaths)")
                WatchSessionManager.shared.sendCurrentStateToPhone()
            }
        }
    }

    func resetSession() {
        // Send current progress before resetting
        let completedBreaths = timerCount / breathDuration
        if completedBreaths > 0 {
            store.breathe = completedBreaths
            print("Breathe session reset - sending partial breathe progress: \(completedBreaths)")
            WatchSessionManager.shared.sendCurrentStateToPhone()
        }
        
        sessionRunning = false
        timerCount = 0
        isInhale = true
        timer?.invalidate()
        timer = nil
        WKInterfaceDevice.current().play(.click)
    }
}

struct BreatheView_Previews: PreviewProvider {
    static var previews: some View {
        BreatheView()
    }
}
