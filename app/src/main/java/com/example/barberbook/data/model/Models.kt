package com.example.barberbook.data.model

data class User(
    val id: String = "",
    val fullName: String = "",
    val phoneNumber: String = "",
    val role: String = "", // "customer" or "barber"
    val profileImageUrl: String = "",
    val memberSince: Long = System.currentTimeMillis()
)

data class Barber(
    val userId: String = "",
    val shopName: String = "",
    val barberName: String = "",
    val description: String = "",
    val address: String = "",
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val rating: Float = 0f,
    val reviewCount: Int = 0,
    val isOnline: Boolean = true,
    val bannerImageUrl: String = "",
    val profileImageUrl: String = "",
    val startingPrice: Double = 0.0,
    val workingHours: Map<String, WorkingDay> = emptyMap() // "Monday" -> WorkingDay
)

data class WorkingDay(
    val isOpen: Boolean = true,
    val openTime: String = "09:00",
    val closeTime: String = "21:00",
    val breaks: List<TimeRange> = emptyList()
)

data class TimeRange(
    val startTime: String = "",
    val endTime: String = ""
)

data class Service(
    val id: String = "",
    val barberId: String = "",
    val name: String = "",
    val durationMinutes: Int = 30,
    val price: Double = 0.0,
    val isEnabled: Boolean = true
)

data class Booking(
    val id: String = "",
    val customerId: String = "",
    val barberId: String = "",
    val shopName: String = "",
    val barberName: String = "",
    val customerName: String = "",
    val services: List<Service> = emptyList(),
    val date: Long = 0, // Timestamp for the day
    val timeSlot: String = "", // e.g., "10:30"
    val totalPrice: Double = 0.0,
    val status: String = "upcoming", // "upcoming", "completed", "cancelled", "in_progress"
    val createdAt: Long = System.currentTimeMillis(),
    val note: String = ""
)

data class Review(
    val id: String = "",
    val bookingId: String = "",
    val barberId: String = "",
    val customerId: String = "",
    val customerName: String = "",
    val rating: Float = 0f,
    val comment: String = "",
    val photos: List<String> = emptyList(),
    val timestamp: Long = System.currentTimeMillis()
)