package com.example.barberbook.ui.auth

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.example.barberbook.R
import com.example.barberbook.databinding.FragmentLoginBinding

class LoginFragment : Fragment() {

    private var _binding: FragmentLoginBinding? = null
    private val binding get() = _binding!!
    private val args: LoginFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentLoginBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val role = args.role
        binding.title.text = if (role == "customer") "Customer Login" else "Barber Login"

        binding.sendOtpButton.setOnClickListener {
            // Mock OTP process
            binding.phoneInputLayout.visibility = View.GONE
            binding.fullNameInputLayout.visibility = View.GONE
            binding.sendOtpButton.visibility = View.GONE
            
            binding.otpInputLayout.visibility = View.VISIBLE
            binding.verifyOtpButton.visibility = View.VISIBLE
        }

        binding.verifyOtpButton.setOnClickListener {
            // Mock verification success
            if (role == "customer") {
                findNavController().navigate(R.id.action_loginFragment_to_customerHomeFragment)
            } else {
                findNavController().navigate(R.id.action_loginFragment_to_barberDashboardFragment)
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}