package com.example.barberbook.ui.barber.services

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.barberbook.databinding.FragmentBarberServicesBinding

class BarberServicesFragment : Fragment() {
    private var _binding: FragmentBarberServicesBinding? = null
    private val binding get() = _binding!!
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBarberServicesBinding.inflate(inflater, container, false)
        return binding.root
    }
}