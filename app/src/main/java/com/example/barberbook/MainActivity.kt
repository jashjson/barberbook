package com.example.barberbook

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.NavigationUI
import androidx.navigation.ui.setupWithNavController
import com.example.barberbook.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController

        // Setup bottom navigation with navController
        binding.bottomNav.setupWithNavController(navController)

        // Control visibility of bottom navigation based on destination
        navController.addOnDestinationChangedListener { _, destination, _ ->
            when (destination.id) {
                R.id.splashFragment, 
                R.id.roleSelectionFragment, 
                R.id.loginFragment -> {
                    binding.bottomNav.visibility = View.GONE
                }
                R.id.barberDashboardFragment,
                R.id.barberAppointmentsFragment,
                R.id.barberServicesFragment,
                R.id.barberProfileFragment -> {
                    binding.bottomNav.visibility = View.VISIBLE
                    binding.bottomNav.menu.clear()
                    binding.bottomNav.inflateMenu(R.menu.barber_nav_menu)
                }
                else -> {
                    binding.bottomNav.visibility = View.VISIBLE
                    binding.bottomNav.menu.clear()
                    binding.bottomNav.inflateMenu(R.menu.bottom_nav_menu)
                }
            }
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        return navController.navigateUp() || super.onSupportNavigateUp()
    }
}