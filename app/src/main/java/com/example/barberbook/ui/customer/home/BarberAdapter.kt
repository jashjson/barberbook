package com.example.barberbook.ui.customer.home

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.barberbook.R
import com.example.barberbook.data.model.Barber
import com.example.barberbook.databinding.ItemBarberCardBinding

class BarberAdapter(private val onBarberClick: (Barber) -> Unit) :
    ListAdapter<Barber, BarberAdapter.BarberViewHolder>(BarberDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BarberViewHolder {
        val binding = ItemBarberCardBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return BarberViewHolder(binding)
    }

    override fun onBindViewHolder(holder: BarberViewHolder, position: Int) {
        val barber = getItem(position)
        holder.bind(barber)
    }

    inner class BarberViewHolder(private val binding: ItemBarberCardBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(barber: Barber) {
            binding.barberName.text = barber.barberName
            binding.shopName.text = barber.shopName
            binding.ratingText.text = "${barber.rating} (${barber.reviewCount} reviews)"
            binding.startingPrice.text = "From ₹${barber.startingPrice.toInt()}"
            binding.statusBadge.text = if (barber.isOnline) "Open" else "Closed"
            binding.statusBadge.setBackgroundResource(
                if (barber.isOnline) R.drawable.badge_open else R.drawable.badge_closed
            )

            Glide.with(binding.root.context)
                .load(barber.profileImageUrl)
                .placeholder(R.drawable.ic_home)
                .into(binding.barberImage)

            binding.root.setOnClickListener { onBarberClick(barber) }
        }
    }

    class BarberDiffCallback : DiffUtil.ItemCallback<Barber>() {
        override fun areItemsTheSame(oldItem: Barber, newItem: Barber): Boolean {
            return oldItem.userId == newItem.userId
        }

        override fun areContentsTheSame(oldItem: Barber, newItem: Barber): Boolean {
            return oldItem == newItem
        }
    }
}