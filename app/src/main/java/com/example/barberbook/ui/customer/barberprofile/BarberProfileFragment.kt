package com.example.barberbook.ui.customer.barberprofile

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.navArgs
import com.bumptech.glide.Glide
import com.example.barberbook.databinding.FragmentBarberProfileBinding

class BarberProfileFragment : Fragment() {

    private var _binding: FragmentBarberProfileBinding? = null
    private val binding get() = _binding!!
    // private val args: BarberProfileFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentBarberProfileBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        // Mock data for now
        binding.barberName.text = "Raj Barber"
        binding.shopName.text = "Classic Salon"
        binding.ratingText.text = "4.8 (120 reviews)"
        
        binding.bookAppointmentButton.setOnClickListener {
            // Navigate to Booking Screen
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}