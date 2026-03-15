import '../models/models.dart';

// ─────────────────────────────────────────
//  DUMMY DATA — Replace with Firebase calls in Phase 5
// ─────────────────────────────────────────

// ── Barber A — Rajesh (logged-in barber) ──
const String kCurrentBarberId = 'barber_001';

final List<ServiceModel> rajeshServices = [
  const ServiceModel(id: 's1', name: 'Haircut', price: 200, durationMin: 30),
  const ServiceModel(id: 's2', name: 'Beard Trim', price: 150, durationMin: 20),
  const ServiceModel(
    id: 's3',
    name: 'Haircut + Beard',
    price: 350,
    durationMin: 45,
  ),
  const ServiceModel(id: 's4', name: 'Shave', price: 100, durationMin: 15),
  const ServiceModel(id: 's5', name: 'Hair Wash', price: 100, durationMin: 15),
  const ServiceModel(
    id: 's6',
    name: 'Full Grooming',
    price: 500,
    durationMin: 60,
  ),
];

final BarberModel currentBarber = BarberModel(
  id: kCurrentBarberId,
  name: 'Rajesh Kumar',
  shopName: 'Rajesh Barber Shop',
  specialty: 'Fades & Beard Styling',
  location: 'Anna Nagar, Chennai',
  bio:
      'Professional barber with 8+ years of experience. Specializing in fades, beard styling, and classic cuts.',
  rating: 4.9,
  reviewCount: 124,
  totalClients: 248,
  experienceYears: 8,
  initial: 'R',
  isOpen: true,
  status: 'open',
  services: rajeshServices,
);

// ── All barbers (for customer discovery) ──
final List<ServiceModel> sureshServices = [
  const ServiceModel(id: 's1', name: 'Haircut', price: 180, durationMin: 30),
  const ServiceModel(id: 's2', name: 'Hair Wash', price: 80, durationMin: 15),
  const ServiceModel(id: 's3', name: 'Grooming', price: 400, durationMin: 50),
  const ServiceModel(id: 's4', name: 'Beard Trim', price: 120, durationMin: 20),
];

final List<ServiceModel> vimalServices = [
  const ServiceModel(id: 's1', name: 'Haircut', price: 250, durationMin: 35),
  const ServiceModel(id: 's2', name: 'Coloring', price: 600, durationMin: 60),
  const ServiceModel(id: 's3', name: 'Beard', price: 150, durationMin: 20),
];

final List<ServiceModel> kiranServices = [
  const ServiceModel(id: 's1', name: 'Kids Cut', price: 150, durationMin: 25),
  const ServiceModel(id: 's2', name: 'Haircut', price: 200, durationMin: 30),
  const ServiceModel(id: 's3', name: 'Beard', price: 100, durationMin: 15),
  const ServiceModel(id: 's4', name: 'Full Pack', price: 400, durationMin: 55),
];

final List<ServiceModel> mohanServices = [
  const ServiceModel(id: 's1', name: 'Shave', price: 120, durationMin: 20),
  const ServiceModel(id: 's2', name: 'Haircut', price: 180, durationMin: 30),
  const ServiceModel(id: 's3', name: 'Massage', price: 200, durationMin: 30),
];

final List<BarberModel> allBarbers = [
  currentBarber,
  BarberModel(
    id: 'barber_002',
    name: 'Suresh Styles',
    shopName: 'Suresh Saloon',
    specialty: 'Classic & Modern Cuts',
    location: 'T. Nagar, Chennai',
    bio: '5 years experience in classic and modern hair styling.',
    rating: 4.7,
    reviewCount: 89,
    totalClients: 180,
    experienceYears: 5,
    initial: 'S',
    isOpen: true,
    status: 'open',
    services: sureshServices,
  ),
  BarberModel(
    id: 'barber_003',
    name: 'Vimal Cuts',
    shopName: 'Vimal Hair Studio',
    specialty: 'Hair Coloring & Styling',
    location: 'Velachery, Chennai',
    bio: 'Specialist in hair coloring and creative styles.',
    rating: 4.5,
    reviewCount: 67,
    totalClients: 130,
    experienceYears: 6,
    initial: 'V',
    isOpen: false,
    status: 'break',
    services: vimalServices,
  ),
  BarberModel(
    id: 'barber_004',
    name: 'Kiran Barber',
    shopName: 'Kiran Family Salon',
    specialty: 'Kids & Family Cuts',
    location: 'Adyar, Chennai',
    bio: 'Family-friendly barber shop, great with kids.',
    rating: 4.8,
    reviewCount: 102,
    totalClients: 200,
    experienceYears: 7,
    initial: 'K',
    isOpen: true,
    status: 'open',
    services: kiranServices,
  ),
  BarberModel(
    id: 'barber_005',
    name: 'Mohan Saloon',
    shopName: 'Mohan Classic',
    specialty: 'Traditional Shaving',
    location: 'Mylapore, Chennai',
    bio: 'Traditional barber specializing in hot towel shaves.',
    rating: 4.6,
    reviewCount: 78,
    totalClients: 160,
    experienceYears: 10,
    initial: 'M',
    isOpen: true,
    status: 'open',
    services: mohanServices,
  ),
];

// ── Appointments (barber view) ──
List<AppointmentModel> barberAppointments = [
  const AppointmentModel(
    id: 'a1',
    customerId: 'c1',
    customerName: 'Arjun Kumar',
    customerInitial: 'A',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's3',
    serviceName: 'Haircut + Beard',
    price: 350,
    date: 'Today',
    timeSlot: '10:00 AM',
    status: 'confirmed',
  ),
  const AppointmentModel(
    id: 'a2',
    customerId: 'c2',
    customerName: 'Ravi Shankar',
    customerInitial: 'R',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's1',
    serviceName: 'Haircut',
    price: 200,
    date: 'Today',
    timeSlot: '11:00 AM',
    status: 'confirmed',
  ),
  const AppointmentModel(
    id: 'a3',
    customerId: 'c3',
    customerName: 'Karthik M',
    customerInitial: 'K',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's2',
    serviceName: 'Beard Trim',
    price: 150,
    date: 'Today',
    timeSlot: '12:30 PM',
    status: 'pending',
  ),
  const AppointmentModel(
    id: 'a4',
    customerId: 'c4',
    customerName: 'Suresh Babu',
    customerInitial: 'S',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's1',
    serviceName: 'Haircut',
    price: 200,
    date: 'Today',
    timeSlot: '2:00 PM',
    status: 'pending',
  ),
  const AppointmentModel(
    id: 'a5',
    customerId: 'c5',
    customerName: 'Vijay T',
    customerInitial: 'V',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's6',
    serviceName: 'Full Grooming',
    price: 500,
    date: 'Yesterday',
    timeSlot: '3:00 PM',
    status: 'completed',
  ),
  const AppointmentModel(
    id: 'a6',
    customerId: 'c6',
    customerName: 'Manoj P',
    customerInitial: 'M',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's1',
    serviceName: 'Haircut',
    price: 200,
    date: 'Yesterday',
    timeSlot: '11:00 AM',
    status: 'completed',
  ),
];

// ── Customer bookings ──
List<AppointmentModel> customerBookings = [
  const AppointmentModel(
    id: 'b1',
    customerId: 'cust_001',
    customerName: 'Arun Kumar',
    customerInitial: 'A',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's3',
    serviceName: 'Haircut + Beard',
    price: 350,
    date: 'Tomorrow',
    timeSlot: '10:00 AM',
    status: 'confirmed',
  ),
  const AppointmentModel(
    id: 'b2',
    customerId: 'cust_001',
    customerName: 'Arun Kumar',
    customerInitial: 'A',
    barberId: 'barber_002',
    barberName: 'Suresh Styles',
    serviceId: 's1',
    serviceName: 'Haircut',
    price: 180,
    date: 'Sat, Dec 14',
    timeSlot: '2:00 PM',
    status: 'upcoming',
  ),
  const AppointmentModel(
    id: 'b3',
    customerId: 'cust_001',
    customerName: 'Arun Kumar',
    customerInitial: 'A',
    barberId: kCurrentBarberId,
    barberName: 'Rajesh Kumar',
    serviceId: 's2',
    serviceName: 'Beard Trim',
    price: 150,
    date: 'Mon, Dec 9',
    timeSlot: '11:00 AM',
    status: 'completed',
  ),
  const AppointmentModel(
    id: 'b4',
    customerId: 'cust_001',
    customerName: 'Arun Kumar',
    customerInitial: 'A',
    barberId: 'barber_003',
    barberName: 'Vimal Cuts',
    serviceId: 's1',
    serviceName: 'Haircut',
    price: 250,
    date: 'Sat, Dec 7',
    timeSlot: '3:00 PM',
    status: 'completed',
    reviewLeft: true,
  ),
  const AppointmentModel(
    id: 'b5',
    customerId: 'cust_001',
    customerName: 'Arun Kumar',
    customerInitial: 'A',
    barberId: 'barber_004',
    barberName: 'Kiran Barber',
    serviceId: 's4',
    serviceName: 'Full Pack',
    price: 400,
    date: 'Mon, Dec 2',
    timeSlot: '12:00 PM',
    status: 'cancelled',
  ),
];

// ── Reviews ──
final List<ReviewModel> barberReviews = [
  const ReviewModel(
    id: 'r1',
    barberId: kCurrentBarberId,
    customerId: 'c1',
    customerName: 'Arun K',
    customerInitial: 'A',
    rating: 5,
    comment: 'Best haircut I have had in years. Very professional!',
    date: '2 days ago',
  ),
  const ReviewModel(
    id: 'r2',
    barberId: kCurrentBarberId,
    customerId: 'c2',
    customerName: 'Priya S',
    customerInitial: 'P',
    rating: 4,
    comment: 'Great service, clean place. Slightly long wait time.',
    date: '1 week ago',
  ),
  const ReviewModel(
    id: 'r3',
    barberId: kCurrentBarberId,
    customerId: 'c3',
    customerName: 'Rahul M',
    customerInitial: 'R',
    rating: 5,
    comment: 'Amazing fade! Will definitely come back.',
    date: '2 weeks ago',
  ),
];

// ── Notifications ──
final List<NotificationModel> customerNotifications = [
  const NotificationModel(
    id: 'n1',
    type: 'confirmed',
    title: 'Booking Confirmed!',
    message:
        'Rajesh Kumar confirmed your appointment for tomorrow at 10:00 AM.',
    time: '2 min ago',
  ),
  const NotificationModel(
    id: 'n2',
    type: 'reminder',
    title: 'Reminder',
    message: 'Your appointment with Suresh Styles is in 1 hour. Get ready!',
    time: '1 hour ago',
  ),
  const NotificationModel(
    id: 'n3',
    type: 'cancelled',
    isRead: true,
    title: 'Booking Cancelled',
    message: 'Kiran Barber cancelled your appointment on Dec 5. Please rebook.',
    time: '2 days ago',
  ),
  const NotificationModel(
    id: 'n4',
    type: 'review',
    isRead: true,
    title: 'New Review Reply',
    message:
        'Rajesh Kumar replied to your review: "Thank you for the kind words!"',
    time: '3 days ago',
  ),
  const NotificationModel(
    id: 'n5',
    type: 'promo',
    isRead: true,
    title: 'Special Offer 🎉',
    message: 'Get 20% off your next booking this weekend. Use code WEEKEND20.',
    time: '5 days ago',
  ),
];

// ── Earnings entries ──
final List<EarningsEntry> earningsHistory = [
  const EarningsEntry(
    customerName: 'Arjun Kumar',
    customerInitial: 'A',
    service: 'Haircut + Beard',
    date: 'Today, 10:00 AM',
    amount: 350,
  ),
  const EarningsEntry(
    customerName: 'Ravi Shankar',
    customerInitial: 'R',
    service: 'Haircut',
    date: 'Today, 11:00 AM',
    amount: 200,
  ),
  const EarningsEntry(
    customerName: 'Karthik M',
    customerInitial: 'K',
    service: 'Beard Trim',
    date: 'Today, 12:30 PM',
    amount: 150,
  ),
  const EarningsEntry(
    customerName: 'Suresh Babu',
    customerInitial: 'S',
    service: 'Haircut',
    date: 'Yesterday, 2:00 PM',
    amount: 200,
  ),
  const EarningsEntry(
    customerName: 'Vijay T',
    customerInitial: 'V',
    service: 'Full Grooming',
    date: 'Yesterday, 4:00 PM',
    amount: 500,
  ),
  const EarningsEntry(
    customerName: 'Manoj P',
    customerInitial: 'M',
    service: 'Haircut',
    date: 'Mon, 11:00 AM',
    amount: 200,
  ),
  const EarningsEntry(
    customerName: 'Dinesh R',
    customerInitial: 'D',
    service: 'Full Grooming',
    date: 'Mon, 3:00 PM',
    amount: 500,
  ),
];

// ── Booked time slots (for booking screen) ──
const List<String> bookedTimeSlots = ['10:00 AM', '11:00 AM', '2:30 PM'];

// ── Favourite barber IDs for current customer ──
List<String> favouriteBarberIds = ['barber_001', 'barber_004'];

// ── All time slots ──
const List<String> allTimeSlots = [
  '9:00 AM',
  '9:30 AM',
  '10:00 AM',
  '10:30 AM',
  '11:00 AM',
  '11:30 AM',
  '12:00 PM',
  '2:00 PM',
  '2:30 PM',
  '3:00 PM',
  '3:30 PM',
  '4:00 PM',
  '4:30 PM',
  '5:00 PM',
];
