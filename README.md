# ZenTrack

ZenTrack is a modern wellness and productivity tracker for iOS and Apple Watch. Track your habits, mood, water intake, focus time, breathing sessions, and medicine reminders—seamlessly synced between your iPhone and Apple Watch.

---

## 🚀 Overview
ZenTrack helps you build healthy routines and stay mindful of your daily wellness. With real-time sync between your iPhone and Apple Watch, you can log and review your progress anywhere, anytime.

---

## ✨ Features

- **Dashboard:** See today's mood, water, focus, breathe, habits, and medicine at a glance.
- **History:** Browse and tap any date for a detailed daily summary.
- **Weekly Summary:** View 7-day averages, best days, and habit completion rates.
- **Habit Management:** Add, remove, and categorize habits (Health, Work, Personal, etc.).
- **Medicine Reminders:** Set and track daily medicine.
- **Apple Watch App:**
  - Toggle habits on your wrist
  - Start focus timers and breathing sessions
  - Mark medicines as taken
  - See streaks and reset habits for the day
- **Real-Time Sync:** All data syncs instantly between iPhone and Watch using Apple's WatchConnectivity.

---

## 📱 Screenshots

> _Add screenshots of the Dashboard, History, Weekly Summary, and Watch app here._

---

## 🛠 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/zentack.git
   cd zentrack
   ```
2. **Open in Xcode:**
   - Open `ZenTrack Mobile.xcodeproj` in Xcode (latest recommended).
3. **Build & Run:**
   - Select the iOS target to run on your iPhone/iPad.
   - Select the Watch target to run on your Apple Watch (or simulator).

---

## 🚦 Usage

- **Add habits and medicine reminders** in the iOS app under Settings.
- **Track your day**: Log mood, water, focus, breathe, and habits on either device.
- **Syncs automatically**: Changes on one device appear on the other in real time.
- **Review your progress** in Dashboard, History, and Weekly Summary.

---

## 🔄 Data Sync
- Uses Apple's `WCSession` for real-time, secure sync between iPhone and Watch.
- All data is stored locally using `UserDefaults` and Codable structs.
- No external servers or accounts required—your data stays private.

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgements
- Built with SwiftUI, Combine, and WatchConnectivity.
- Inspired by the need for simple, cross-device wellness tracking.

---

**ZenTrack** — _Track your habits. Find your balance._ 