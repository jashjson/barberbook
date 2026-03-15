class BarberModel {
  final String id;
  final String name;
  final String shopName;
  final String specialty;
  final String location;
  final String bio;
  final double rating;
  final int reviewCount;
  final int totalClients;
  final int experienceYears;
  final String initial;
  final bool isOpen;
  final String status; // open | busy | break
  final List<ServiceModel> services;

  const BarberModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.specialty,
    required this.location,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.totalClients,
    required this.experienceYears,
    required this.initial,
    required this.isOpen,
    required this.status,
    required this.services,
  });
}

class ServiceModel {
  final String id;
  final String name;
  final int price;
  final int durationMin;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMin,
    this.isActive = true,
  });

  String get durationLabel => '$durationMin min';
}

class AppointmentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerInitial;
  final String barberId;
  final String barberName;
  final String serviceId;
  final String serviceName;
  final int price;
  final String date;
  final String timeSlot;
  final String status; // pending | confirmed | cancelled | completed
  final bool reviewLeft;

  const AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerInitial,
    required this.barberId,
    required this.barberName,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.reviewLeft = false,
  });

  AppointmentModel copyWith({String? status, bool? reviewLeft}) {
    return AppointmentModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerInitial: customerInitial,
      barberId: barberId,
      barberName: barberName,
      serviceId: serviceId,
      serviceName: serviceName,
      price: price,
      date: date,
      timeSlot: timeSlot,
      status: status ?? this.status,
      reviewLeft: reviewLeft ?? this.reviewLeft,
    );
  }
}

class ReviewModel {
  final String id;
  final String barberId;
  final String customerId;
  final String customerName;
  final String customerInitial;
  final int rating;
  final String comment;
  final String date;

  const ReviewModel({
    required this.id,
    required this.barberId,
    required this.customerId,
    required this.customerName,
    required this.customerInitial,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class NotificationModel {
  final String id;
  final String type; // confirmed | reminder | cancelled | review | promo
  final String title;
  final String message;
  final String time;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class EarningsEntry {
  final String customerName;
  final String customerInitial;
  final String service;
  final String date;
  final int amount;

  const EarningsEntry({
    required this.customerName,
    required this.customerInitial,
    required this.service,
    required this.date,
    required this.amount,
  });
}
