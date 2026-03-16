package com.example.barberbook.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.barberbook.data.model.Barber
import com.example.barberbook.data.repository.BarberRepository
import kotlinx.coroutines.launch

class CustomerHomeViewModel : ViewModel() {
    private val repository = BarberRepository()

    private val _barbers = MutableLiveData<List<Barber>>()
    val barbers: LiveData<List<Barber>> = _barbers

    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    fun loadBarbers() {
        viewModelScope.launch {
            _isLoading.value = true
            val barberList = repository.getAllBarbers()
            _barbers.value = barberList
            _isLoading.value = false
        }
    }
}