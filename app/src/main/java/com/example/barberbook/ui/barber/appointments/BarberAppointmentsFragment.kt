package com.example.barberbook.ui.barber.appointments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.barberbook.databinding.FragmentBarberAppointmentsBinding

class BarberAppointmentsFragment : Fragment() {
    private var _binding: FragmentBarberAppointmentsBinding? = null
    private val binding get() = _binding!!
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBarberAppointmentsBinding.inflate(inflater, container, false)
        return binding.root
    }
}