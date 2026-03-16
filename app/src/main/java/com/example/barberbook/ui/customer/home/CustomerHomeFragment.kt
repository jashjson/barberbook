package com.example.barberbook.ui.customer.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.barberbook.databinding.FragmentCustomerHomeBinding

import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.barberbook.viewmodel.CustomerHomeViewModel

class CustomerHomeFragment : Fragment() {

    private var _binding: FragmentCustomerHomeBinding? = null
    private val binding get() = _binding!!
    private val viewModel: CustomerHomeViewModel by viewModels()
    private lateinit var barberAdapter: BarberAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentCustomerHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        observeViewModel()
        
        viewModel.loadBarbers()
    }

    private fun setupRecyclerView() {
        barberAdapter = BarberAdapter { barber ->
            // Navigate to Barber Profile
        }
        binding.nearbyBarbersRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = barberAdapter
        }
    }

    private fun observeViewModel() {
        viewModel.barbers.observe(viewLifecycleOwner) { barbers ->
            barberAdapter.submitList(barbers)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}