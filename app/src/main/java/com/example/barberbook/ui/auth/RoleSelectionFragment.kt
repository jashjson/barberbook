package com.example.barberbook.ui.auth

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.barberbook.R
import com.example.barberbook.databinding.FragmentRoleSelectionBinding

class RoleSelectionFragment : Fragment() {

    private var _binding: FragmentRoleSelectionBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentRoleSelectionBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.customerCard.setOnClickListener {
            // Navigate to Login with customer role
            val action = RoleSelectionFragmentDirections.actionRoleSelectionFragmentToLoginFragment("customer")
            findNavController().navigate(action)
        }

        binding.barberCard.setOnClickListener {
            // Navigate to Login with barber role
            val action = RoleSelectionFragmentDirections.actionRoleSelectionFragmentToLoginFragment("barber")
            findNavController().navigate(action)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}