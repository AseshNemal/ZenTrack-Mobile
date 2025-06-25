import SwiftUI
import WatchKit
import WatchConnectivity

struct TimerView: View {
    @State private var timeRemaining = 25 * 60
    @State private var timerRunning = false
    @State private var timer: Timer? = nil
    @ObservedObject private var store = WatchDataStore.shared

    var progress: Double {
        1.0 - Double(timeRemaining) / Double(25 * 60)
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.green)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.green)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: progress)
                Text(timeString(time: timeRemaining))
                    .font(.title)
                    .bold()
            }
            .frame(width: 120, height: 120)

            HStack(spacing: 20) {
                Button(action: {
                    if !timerRunning {
                        startTimer()
                    }
                }) {
                    Text("Start")
                        .font(.headline)
                        .padding()
                        .background(timerRunning ? Color.gray.opacity(0.3) : Color.green.opacity(0.7))
                        .cornerRadius(10)
                }
                .disabled(timerRunning)

                Button(action: {
                    resetTimer()
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
        .navigationTitle("Focus Timer")
    }

    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                timer = nil
                timerRunning = false
                WKInterfaceDevice.current().play(.notification)
                // Send focus data to iPhone
                let completedMinutes = 25 // since timer is for 25 minutes
                store.focus = completedMinutes
                WatchSessionManager.shared.sendCurrentStateToPhone()
            }
        }
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 25 * 60
        timerRunning = false
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
