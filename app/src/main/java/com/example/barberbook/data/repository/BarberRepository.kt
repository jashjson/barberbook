package com.example.barberbook.data.repository

import com.example.barberbook.data.model.Barber
import com.example.barberbook.data.model.Service
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

class BarberRepository {
    private val db = FirebaseFirestore.getInstance()

    suspend fun getAllBarbers(): List<Barber> {
        return try {
            val snapshot = db.collection("barbers").get().await()
            snapshot.toObjects(Barber::class.java)
        } catch (e: Exception) {
            emptyList()
        }
    }

    suspend fun getBarberById(barberId: String): Barber? {
        return try {
            val snapshot = db.collection("barbers").document(barberId).get().await()
            snapshot.toObject(Barber::class.java)
        } catch (e: Exception) {
            null
        }
    }

    suspend fun getServicesForBarber(barberId: String): List<Service> {
        return try {
            val snapshot = db.collection("services")
                .whereEqualTo("barberId", barberId)
                .get().await()
            snapshot.toObjects(Service::class.java)
        } catch (e: Exception) {
            emptyList()
        }
    }
}