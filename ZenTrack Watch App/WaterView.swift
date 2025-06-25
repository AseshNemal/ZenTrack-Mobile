import SwiftUI
import WatchKit
import WatchConnectivity

struct WaterView: View {
    private let dailyGoal = 2000
    private let stepAmount = 250
    @ObservedObject private var store = WatchDataStore.shared

    var progress: Double {
        min(Double(store.water) / Double(dailyGoal), 1.0)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Water Intake")
                .font(.headline)
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: progress)
                Text("\(store.water) ml")
                    .font(.title2)
                    .bold()
            }
            .frame(width: 100, height: 100)

            Button(action: {
                store.water += stepAmount
                if store.water > dailyGoal {
                    store.water = dailyGoal
                }
                WKInterfaceDevice.current().play(.click)
                WatchSessionManager.shared.sendCurrentStateToPhone()
            }) {
                Text("Add 250ml")
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            Spacer()
            Button(action: {
                store.water = 0
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
        .navigationTitle("Water Log")
    }
}

struct WaterView_Previews: PreviewProvider {
    static var previews: some View {
        WaterView()
    }
}
