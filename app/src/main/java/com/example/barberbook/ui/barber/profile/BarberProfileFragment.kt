package com.example.barberbook.ui.barber.profile

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.barberbook.databinding.FragmentBarberProfileBinding

class BarberProfileFragment : Fragment() {
    private var _binding: FragmentBarberProfileBinding? = null
    private val binding get() = _binding!!
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBarberProfileBinding.inflate(inflater, container, false)
        return binding.root
    }
}