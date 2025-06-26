import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Mood Tracker", destination: MoodView())
                NavigationLink("Water Log", destination: WaterView())
                NavigationLink("Focus Timer", destination: TimerView())
                NavigationLink("Breathe", destination: BreatheView())
                NavigationLink("Habit Tracker", destination: HabitView())
                NavigationLink("Medicine", destination: MedicineView())
            }
            .navigationTitle("ZenTrack")
        }
    }
}

#Preview {
    ContentView()
}
