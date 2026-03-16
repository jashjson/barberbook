# ✂️ BarberBook

> A seamless barber appointment booking app for Android — connecting customers with local barbers in just a few taps.

![Platform](https://img.shields.io/badge/Platform-Android-green) ![Language](https://img.shields.io/badge/Language-Kotlin-blue) ![Backend](https://img.shields.io/badge/Backend-Firebase-orange) ![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

---

## 📱 About

BarberBook is an Android app that lets customers discover nearby barbers, book appointments, and manage their visits — while giving barbers a powerful dashboard to manage their schedule, services, and earnings. No passwords, no friction — just phone-based OTP login and you're in.

---

## ✨ Features

### 👤 Authentication
- Phone number + OTP login (no email/password needed)
- Auto OTP read via SMS Retriever API
- Role-based onboarding — sign up as a **Customer** or **Barber**

### 🧑 Customer Side
- Browse nearby barbers with distance, ratings, and availability
- View barber profiles — services, gallery, reviews, working hours
- Multi-service booking with date & time slot selection
- Reschedule or cancel upcoming appointments
- Leave star ratings and written reviews
- Save favourite barbers for quick re-booking
- In-app notification history

### 💈 Barber Side
- Personal dashboard with today's bookings and earnings summary
- Manage services — add, edit, or disable with custom pricing & duration
- Set weekly working hours and block specific dates
- Mark appointments as done or cancel with a reason
- Earnings tracker — daily, weekly, monthly view
- Online / Offline toggle to pause new bookings

### 🔔 Notifications (FCM)
- Booking confirmations and reminders
- Cancellation alerts for both roles
- Review reminders after completed appointments

---

## ⚡ Pros

- 🔐 **Frictionless login** — OTP auto-read means zero manual input
- 📍 **Location-aware** — shows barbers sorted by proximity
- 🎯 **Dual-role app** — one app, two complete experiences
- 📅 **Smart scheduling** — real-time slot availability, no double bookings
- 🌙 **Dark mode support** — follows system theme
- 🧱 **Clean architecture** — MVVM pattern, easy to scale and maintain
- 🔔 **Real-time updates** — Firebase keeps data in sync instantly

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Language | Kotlin |
| UI | XML + Material Design 3 |
| Architecture | MVVM (ViewModel + LiveData) |
| Navigation | Jetpack Navigation Component |
| Auth | Firebase Phone Authentication |
| Database | Firebase Firestore |
| Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging (FCM) |
| Maps | Google Maps SDK + Places API |
| Image Loading | Glide |
| Animations | Lottie |

---

## 🚀 Getting Started

### Prerequisites
- Android Studio Hedgehog or later
- Android device / emulator running API 24+
- A Firebase project with Phone Auth enabled
- Google Maps API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/BarberBook.git
   cd BarberBook
   ```

2. **Connect Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project and add an Android app
   - Download `google-services.json` and place it in the `/app` directory

3. **Add your Google Maps API Key**
   - Open `local.properties` and add:
   ```
   MAPS_API_KEY=your_api_key_here
   ```

4. **Build and run**
   - Open the project in Android Studio
   - Sync Gradle and hit **Run ▶️**

---

## 📂 Project Structure

```
app/
├── ui/
│   ├── splash/
│   ├── auth/              
│   ├── customer/
│   │   ├── home/
│   │   ├── search/
│   │   ├── barberprofile/
│   │   ├── booking/
│   │   ├── mybookings/
│   │   ├── review/
│   │   └── profile/
│   └── barber/
│       ├── dashboard/
│       ├── appointments/
│       ├── services/
│       ├── schedule/
│       ├── earnings/
│       └── profile/
├── data/
│   ├── model/
│   ├── repository/
│   └── remote/
├── viewmodel/
└── utils/
```

---

## 🎨 Design

- **Primary Color:** Deep Navy `#0D1B2A`
- **Accent Color:** Gold `#F4A828`
- **Font:** Poppins (headings) · Inter (body)
- Smooth animations, shared element transitions, Lottie for empty/success states

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

Built with ❤️ by Sylvia, Jershin Demetrius, J Asher, Jai Akash & Videsh 
