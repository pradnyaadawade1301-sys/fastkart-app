// lib/services/mock_data.dart

import '../models/app_models.dart';

// ── Movie Model ──────────────────────────────────────────────────────────────

class MovieModel {
  final String id;
  final String title;
  final String imageUrl;
  final String genre;
  final String duration;
  final double rating;
  final String language;
  final String releaseDate;
  final List<String> showtimes;
  final int price;

  const MovieModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.language,
    required this.releaseDate,
    required this.showtimes,
    required this.price,
  });
}

// ── Hotel Model ──────────────────────────────────────────────────────────────

class HotelModel {
  final String id;
  final String name;
  final String imageUrl;
  final String location;
  final double rating;
  final int reviewCount;
  final int pricePerNight;
  final List<String> amenities;
  final bool isAvailable;

  const HotelModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.amenities,
    required this.isAvailable,
  });
}

// ── Train Model ──────────────────────────────────────────────────────────────

class TrainModel {
  final String id;
  final String trainNumber;
  final String trainName;
  final String from;
  final String to;
  final String departure;
  final String arrival;
  final String duration;
  final int price;
  final int availableSeats;
  final String classType;

  const TrainModel({
    required this.id,
    required this.trainNumber,
    required this.trainName,
    required this.from,
    required this.to,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.price,
    required this.availableSeats,
    required this.classType,
  });
}

// ── Ride Model ───────────────────────────────────────────────────────────────

class RideModel {
  final String id;
  final String type;
  final String imageUrl;
  final String description;
  final int baseFare;
  final int perKm;
  final int eta;
  final String capacity;

  const RideModel({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.description,
    required this.baseFare,
    required this.perKm,
    required this.eta,
    required this.capacity,
  });
}

// ── Bike Model ───────────────────────────────────────────────────────────────

class BikeModel {
  final String id;
  final String type;
  final String imageUrl;
  final int pricePerHour;
  final double distance;
  final bool isAvailable;

  const BikeModel({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.pricePerHour,
    required this.distance,
    required this.isAvailable,
  });
}

// ── Static functions (used by screens directly) ──────────────────────────────

List<MovieModel> mockMovies() => [
  const MovieModel(
    id: 'm24', title: 'Bhool Bhulaiyaa 3',
    imageUrl: 'https://image.tmdb.org/t/p/w500/3AfHD1HoaQpQwKH8kxRdBKVmzeU.jpg',
    genre: 'Horror · Comedy', duration: '2h 35m', rating: 4.4,
    language: 'Hindi', releaseDate: '1 Nov 2024',
    showtimes: ['10:30 AM', '2:00 PM', '5:30 PM', '9:00 PM', '11:30 PM'], price: 270,
  ),
  const MovieModel(
    id: 'm25', title: 'Singham Again',
    imageUrl: 'https://image.tmdb.org/t/p/w500/2JbNkHg8m7LaBy61LyrnnlenaxY.jpg',
    genre: 'Action · Drama', duration: '2h 45m', rating: 4.3,
    language: 'Hindi', releaseDate: '1 Nov 2024',
    showtimes: ['9:00 AM', '12:00 PM', '3:30 PM', '7:00 PM', '10:15 PM'], price: 290,
  ),
  const MovieModel(
    id: 'm12', title: 'Sikandar',
    imageUrl: 'https://image.tmdb.org/t/p/w500/4MNRH73XmwBK2ycv3qvLpa07O5F.jpg',
    genre: 'Action · Drama', duration: '2h 50m', rating: 4.4,
    language: 'Hindi', releaseDate: '30 Mar 2025',
    showtimes: ['9:30 AM', '1:00 PM', '4:30 PM', '8:00 PM', '11:00 PM'], price: 270,
  ),
  const MovieModel(
    id: 'm13', title: 'Pushpa 2',
    imageUrl: 'https://image.tmdb.org/t/p/w500/bhxZj3y59cK7JtGdV285dhDRaMe.jpg',
    genre: 'Action · Drama', duration: '3h 20m', rating: 4.8,
    language: 'Telugu · Hindi', releaseDate: '5 Dec 2024',
    showtimes: ['9:30 AM', '1:00 PM', '4:30 PM', '8:00 PM'], price: 250,
  ),
  const MovieModel(
    id: 'm11', title: 'Chhaava',
    imageUrl: 'https://image.tmdb.org/t/p/w500/ubRsrzb6NRW8YhVTJ6jG1kpNvCi.jpg',
    genre: 'Historical · Drama', duration: '2h 41m', rating: 4.8,
    language: 'Hindi', releaseDate: '14 Feb 2025',
    showtimes: ['10:00 AM', '1:30 PM', '5:00 PM', '8:30 PM'], price: 220,
  ),
  const MovieModel(
    id: 'm12b', title: 'Raid 2',
    imageUrl: 'https://image.tmdb.org/t/p/w500/562SAxZP1sLuYqDDTuODu3hdGyx.jpg',
    genre: 'Crime · Thriller', duration: '2h 30m', rating: 4.5,
    language: 'Hindi', releaseDate: '1 May 2025',
    showtimes: ['9:00 AM', '12:30 PM', '4:00 PM', '7:30 PM', '10:45 PM'], price: 280,
  ),
  const MovieModel(
    id: 'm21', title: 'Deva',
    imageUrl: 'https://image.tmdb.org/t/p/w500/lqHt4icP1GTaNBeVTxTrwTZdoAW.jpg',
    genre: 'Action · Drama', duration: '2h 20m', rating: 4.3,
    language: 'Hindi', releaseDate: '31 Jan 2025',
    showtimes: ['10:00 AM', '1:30 PM', '5:00 PM', '8:30 PM'], price: 260,
  ),
  const MovieModel(
    id: 'm22', title: 'Azaad',
    imageUrl: 'https://image.tmdb.org/t/p/w500/zUCDf87awNIAIwV5N4NQdA807dGTP.jpg',
    genre: 'Adventure · Drama', duration: '2h 15m', rating: 4.1,
    language: 'Hindi', releaseDate: '17 Jan 2025',
    showtimes: ['9:30 AM', '1:00 PM', '4:30 PM', '8:00 PM'], price: 240,
  ),
  const MovieModel(
    id: 'm23', title: 'Jolly LLB 3',
    imageUrl: 'https://image.tmdb.org/t/p/w500/bwRoU9p5GvjxgPfmIgsfcJ4ydng.jpg',
    genre: 'Comedy · Drama', duration: '2h 25m', rating: 4.2,
    language: 'Hindi', releaseDate: '19 Sep 2025',
    showtimes: ['11:00 AM', '2:30 PM', '6:00 PM', '9:30 PM'], price: 250,
  ),
  const MovieModel(
    id: 'm26', title: 'Retro',
    imageUrl: 'https://image.tmdb.org/t/p/w500/pJPK57REXsaLydpOPgHwWAQMdqz.jpg',
    genre: 'Action · Thriller', duration: '2h 50m', rating: 4.6,
    language: 'Tamil · Hindi', releaseDate: '8 May 2025',
    showtimes: ['9:30 AM', '1:00 PM', '4:30 PM', '8:00 PM'], price: 280,
  ),
  const MovieModel(
    id: 'm27', title: 'Coolie',
    imageUrl: 'https://image.tmdb.org/t/p/w500/bLn0CPzrrqFLicjNTgrzaIyE0gZ.jpg',
    genre: 'Action · Thriller', duration: '2h 55m', rating: 4.7,
    language: 'Tamil · Hindi', releaseDate: '14 Aug 2025',
    showtimes: ['10:00 AM', '1:30 PM', '5:00 PM', '8:30 PM', '11:00 PM'], price: 300,
  ),
  const MovieModel(
    id: 'm28', title: 'Kesari Veer',
    imageUrl: 'https://image.tmdb.org/t/p/w500/fRNg31Cz03qsx3EteqHhcQgLcTa.jpg',
    genre: 'Historical · War', duration: '2h 40m', rating: 4.4,
    language: 'Hindi', releaseDate: '23 May 2025',
    showtimes: ['9:00 AM', '12:30 PM', '4:00 PM', '7:30 PM'], price: 270,
  ),
  const MovieModel(
    id: 'm29', title: 'Welcome 3',
    imageUrl: 'https://image.tmdb.org/t/p/w500/pGTImtIABR9LXFYebcMOs46JsQv.jpg',
    genre: 'Comedy · Action', duration: '2h 20m', rating: 3.9,
    language: 'Hindi', releaseDate: '20 Dec 2024',
    showtimes: ['11:00 AM', '2:30 PM', '6:00 PM', '9:30 PM'], price: 240,
  ),
];

List<HotelModel> mockHotels() => [
  const HotelModel(
    id: 'h1', name: 'Taj Mahal Palace',
    imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
    location: 'Colaba, Mumbai', rating: 4.9, reviewCount: 5832,
    pricePerNight: 18500,
    amenities: ['Pool', 'Spa', 'Restaurant', 'WiFi', 'Gym'], isAvailable: true,
  ),
  const HotelModel(
    id: 'h2', name: 'ITC Grand Central',
    imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400&h=300&fit=crop',
    location: 'Parel, Mumbai', rating: 4.7, reviewCount: 3241,
    pricePerNight: 12000,
    amenities: ['Pool', 'Restaurant', 'WiFi', 'Gym', 'Bar'], isAvailable: true,
  ),
  const HotelModel(
    id: 'h3', name: 'The Leela Mumbai',
    imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
    location: 'Andheri, Mumbai', rating: 4.6, reviewCount: 2187,
    pricePerNight: 9500,
    amenities: ['Pool', 'Spa', 'Restaurant', 'WiFi'], isAvailable: true,
  ),
  const HotelModel(
    id: 'h4', name: 'Trident Nariman Point',
    imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=300&fit=crop',
    location: 'Nariman Point, Mumbai', rating: 4.5, reviewCount: 1943,
    pricePerNight: 8200,
    amenities: ['Restaurant', 'WiFi', 'Gym', 'Bar'], isAvailable: false,
  ),
  const HotelModel(
    id: 'h5', name: 'JW Marriott Mumbai',
    imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
    location: 'Juhu, Mumbai', rating: 4.8, reviewCount: 4102,
    pricePerNight: 14000,
    amenities: ['Pool', 'Spa', 'Restaurant', 'WiFi', 'Gym', 'Bar'], isAvailable: true,
  ),
  const HotelModel(
    id: 'h6', name: 'Ginger Mumbai Airport',
    imageUrl: 'https://images.unsplash.com/photo-1455587734955-081b22074882?w=400&h=300&fit=crop',
    location: 'Santacruz, Mumbai', rating: 4.1, reviewCount: 876,
    pricePerNight: 2800,
    amenities: ['WiFi', 'Restaurant', 'Gym'], isAvailable: true,
  ),
];

List<TrainModel> mockTrains() => [
  const TrainModel(
    id: 't1', trainNumber: '12951', trainName: 'Mumbai Rajdhani',
    from: 'Mumbai Central', to: 'New Delhi',
    departure: '05:00 PM', arrival: '08:35 AM', duration: '15h 35m',
    price: 1580, availableSeats: 24, classType: '3A',
  ),
  const TrainModel(
    id: 't2', trainNumber: '12009', trainName: 'Shatabdi Express',
    from: 'Mumbai CST', to: 'Pune',
    departure: '06:10 AM', arrival: '08:55 AM', duration: '2h 45m',
    price: 380, availableSeats: 54, classType: 'CC',
  ),
  const TrainModel(
    id: 't3', trainNumber: '22221', trainName: 'CSMT Rajdhani',
    from: 'Mumbai CST', to: 'Hazrat Nizamuddin',
    departure: '11:05 AM', arrival: '10:05 AM', duration: '23h 00m',
    price: 1950, availableSeats: 8, classType: '2A',
  ),
  const TrainModel(
    id: 't4', trainNumber: '11001', trainName: 'Udyan Express',
    from: 'Mumbai CST', to: 'Bengaluru',
    departure: '08:05 PM', arrival: '10:30 AM', duration: '14h 25m',
    price: 620, availableSeats: 36, classType: 'SL',
  ),
  const TrainModel(
    id: 't5', trainNumber: '12471', trainName: 'Swaraj Express',
    from: 'Mumbai Bandra', to: 'Jammu Tawi',
    departure: '10:45 PM', arrival: '07:15 AM', duration: '32h 30m',
    price: 880, availableSeats: 62, classType: '3A',
  ),
];

List<RideModel> mockRides() => [
  const RideModel(
    id: 'rd1', type: 'Auto',
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop',
    description: 'Affordable 3-wheeler rides',
    baseFare: 30, perKm: 12, eta: 3, capacity: '3 passengers',
  ),
  const RideModel(
    id: 'rd2', type: 'Mini',
    imageUrl: 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=200&h=200&fit=crop',
    description: 'Compact & budget friendly',
    baseFare: 50, perKm: 14, eta: 5, capacity: '4 passengers',
  ),
  const RideModel(
    id: 'rd3', type: 'Sedan',
    imageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=200&h=200&fit=crop',
    description: 'Comfortable sedan rides',
    baseFare: 80, perKm: 18, eta: 4, capacity: '4 passengers',
  ),
  const RideModel(
    id: 'rd4', type: 'SUV',
    imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=200&h=200&fit=crop',
    description: 'Spacious for groups',
    baseFare: 120, perKm: 22, eta: 7, capacity: '6 passengers',
  ),
  const RideModel(
    id: 'rd5', type: 'Bike',
    imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=200&h=200&fit=crop',
    description: 'Beat the traffic fast',
    baseFare: 20, perKm: 8, eta: 2, capacity: '1 passenger',
  ),
];

List<BikeModel> mockBikes() => [
  const BikeModel(
    id: 'bk1', type: 'Electric Scooter',
    imageUrl: 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=300&h=200&fit=crop',
    pricePerHour: 40, distance: 0.3, isAvailable: true,
  ),
  const BikeModel(
    id: 'bk2', type: 'City Bike',
    imageUrl: 'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=300&h=200&fit=crop',
    pricePerHour: 25, distance: 0.5, isAvailable: true,
  ),
  const BikeModel(
    id: 'bk3', type: 'Electric Scooter',
    imageUrl: 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=300&h=200&fit=crop',
    pricePerHour: 40, distance: 0.8, isAvailable: false,
  ),
  const BikeModel(
    id: 'bk4', type: 'Mountain Bike',
    imageUrl: 'https://images.unsplash.com/photo-1576435728678-68d0fbf94946?w=300&h=200&fit=crop',
    pricePerHour: 35, distance: 1.2, isAvailable: true,
  ),
];

// ── MockData class (used by providers) ───────────────────────────────────────

class MockData {
  static AppUser sampleUser() => const AppUser(
        id: 'u1',
        name: 'Rahul Sharma',
        phone: '+91 98765 43210',
        email: 'rahul.sharma@gmail.com',
        walletBalance: 450.0,
        points: 1280,
        defaultAddress: 'B-204, Andheri West, Mumbai - 400053',
      );

  static List<BannerModel> banners() => [
        const BannerModel(
          id: 'b1',
          imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&h=300&fit=crop',
          title: '50% OFF on First Order',
          subtitle: 'Use code FIRST50',
          targetRoute: '/restaurant',
        ),
        const BannerModel(
          id: 'b2',
          imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&h=300&fit=crop',
          title: 'Free Delivery Today',
          subtitle: 'On orders above ₹299',
          targetRoute: '/restaurant',
        ),
        const BannerModel(
          id: 'b3',
          imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=300&fit=crop',
          title: 'Weekend Special',
          subtitle: 'Up to 30% off on selected restaurants',
          targetRoute: '/restaurant',
        ),
      ];

  static List<CategoryModel> categories() => const [
        CategoryModel(id: 'food',     name: 'Food',     icon: '🍛',  colorValue: 0xFFFF6B35, route: '/restaurants'),      // ✅
        CategoryModel(id: 'movies',   name: 'Movies',   icon: '🎬',  colorValue: 0xFFE91E63, route: '/movies'),            // ✅
        CategoryModel(id: 'hotels',   name: 'Hotels',   icon: '🏨',  colorValue: 0xFF7C4DFF, route: '/hotels'),            // ✅
        CategoryModel(id: 'leisure',  name: 'Leisure',  icon: '🎭',  colorValue: 0xFF00BCD4, route: '/leisure'),
        CategoryModel(id: 'delivery', name: 'Delivery', icon: '🛵',  colorValue: 0xFF4CAF50, route: '/restaurants'),          // ✅ FIXED
        CategoryModel(id: 'ride',     name: 'Ride',     icon: '🚕',  colorValue: 0xFF2196F3, route: '/rides'),             // ✅
        CategoryModel(id: 'bike',     name: 'Bike',     icon: '🏍️', colorValue: 0xFF8BC34A, route: '/bikes'),             // ✅
        CategoryModel(id: 'travel',   name: 'Travel',   icon: '✈️', colorValue: 0xFFFF9800, route: '/flights'),            // ✅
        CategoryModel(id: 'grocery',  name: 'Grocery',  icon: '🛒',  colorValue: 0xFF009688, route: '/grocery'),  // ✅
        CategoryModel(id: 'more',     name: 'More',     icon: '···', colorValue: 0xFF9E9E9E, route: '/category/more'),            // ✅ FIXED
      ];

  static List<Restaurant> restaurants() => [
        Restaurant(
          id: 'r1', name: 'Punjabi Tadka',
          imageUrl: 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=400&h=300&fit=crop',
          coverUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=800&h=400&fit=crop',
          rating: 4.5, reviewCount: 1243, deliveryTime: '30-40 min',
          deliveryFee: 39, minOrder: 199, distance: '1.2 km', isOpen: true,
          categories: ['North Indian', 'Punjabi', 'Tandoor'],
          address: 'Shop 12, Linking Road, Bandra West, Mumbai',
          lat: 19.0596, lng: 72.8295,
          tags: ['Bestseller', 'Pure Veg'],
          description: 'Authentic Punjabi flavours in the heart of Mumbai.',
          menu: _punjabMenu(),
        ),
        Restaurant(
          id: 'r2', name: 'South Spice Kitchen',
          imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400&h=300&fit=crop',
          coverUrl: 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=800&h=400&fit=crop',
          rating: 4.3, reviewCount: 876, deliveryTime: '25-35 min',
          deliveryFee: 0, minOrder: 249, distance: '0.8 km', isOpen: true,
          categories: ['South Indian', 'Dosa', 'Idli'],
          address: '45, SV Road, Andheri West, Mumbai',
          lat: 19.1197, lng: 72.8464,
          tags: ['Free Delivery', 'Top Rated'],
          description: 'Crispy dosas and filter coffee straight from the South.',
          menu: _southMenu(),
        ),
        Restaurant(
          id: 'r3', name: 'Burger Barn',
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
          coverUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=800&h=400&fit=crop',
          rating: 4.1, reviewCount: 542, deliveryTime: '20-30 min',
          deliveryFee: 29, minOrder: 149, distance: '2.1 km', isOpen: true,
          categories: ['Burgers', 'Fast Food', 'Shakes'],
          address: 'Food Court, Infiniti Mall, Malad West, Mumbai',
          lat: 19.1876, lng: 72.8479,
          tags: ['New', 'Trending'],
          description: 'Juicy burgers and thick shakes for every mood.',
          menu: _burgerMenu(),
        ),
        Restaurant(
          id: 'r4', name: 'Pizza House',
          imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop',
          coverUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&h=400&fit=crop',
          rating: 4.4, reviewCount: 2100, deliveryTime: '35-45 min',
          deliveryFee: 49, minOrder: 299, distance: '3.0 km', isOpen: false,
          categories: ['Pizza', 'Italian', 'Pasta'],
          address: '7, Hill Road, Bandra West, Mumbai',
          lat: 19.0504, lng: 72.8403,
          tags: ['Popular'],
          description: 'Wood-fired pizzas and creamy pastas, Italian style.',
          menu: _pizzaMenu(),
        ),
        Restaurant(
          id: 'r5', name: 'Chinese Dragon',
          imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop',
          coverUrl: 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800&h=400&fit=crop',
          rating: 4.2, reviewCount: 689, deliveryTime: '30-40 min',
          deliveryFee: 35, minOrder: 249, distance: '1.7 km', isOpen: true,
          categories: ['Chinese', 'Asian', 'Noodles'],
          address: '22, Turner Road, Bandra West, Mumbai',
          lat: 19.0548, lng: 72.8342,
          tags: ['Must Try'],
          description: 'Indo-Chinese classics done right.',
          menu: _chineseMenu(),
        ),
      ];

  static List<Order> sampleOrders() {
    final rests = restaurants();
    final r1 = rests[0];
    final r2 = rests[1];
    return [
      Order(
        id: 'ord001', restaurantId: r1.id, restaurantName: r1.name,
        restaurantImage: r1.imageUrl,
        items: [
          OrderItemModel(id: r1.menu[0].id, name: r1.menu[0].name, imageUrl: r1.menu[0].imageUrl, quantity: 2, price: r1.menu[0].price),
          OrderItemModel(id: r1.menu[1].id, name: r1.menu[1].name, imageUrl: r1.menu[1].imageUrl, quantity: 1, price: r1.menu[1].price),
        ],
        subtotal: 598, deliveryFee: 29, discount: 50, total: 577,
        status: OrderStatus.delivered,
        deliveryAddress: const DeliveryAddress(label: 'Home', fullAddress: 'B-204, Andheri West, Mumbai - 400053'),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        estimatedDelivery: DateTime.now().subtract(const Duration(days: 2, minutes: -35)),
        driverName: 'Raju Bhaiya', driverPhone: '+91 98765 43210',
        driverImage: 'https://i.pravatar.cc/200?img=3',
        driverLat: 19.0760, driverLng: 72.8777,
      ),
      Order(
        id: 'ord002', restaurantId: r2.id, restaurantName: r2.name,
        restaurantImage: r2.imageUrl,
        items: [
          OrderItemModel(id: r2.menu[0].id, name: r2.menu[0].name, imageUrl: r2.menu[0].imageUrl, quantity: 3, price: r2.menu[0].price),
        ],
        subtotal: 297, deliveryFee: 0, discount: 0, total: 297,
        status: OrderStatus.onTheWay,
        deliveryAddress: const DeliveryAddress(label: 'Home', fullAddress: 'B-204, Andheri West, Mumbai - 400053'),
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        estimatedDelivery: DateTime.now().add(const Duration(minutes: 15)),
        driverName: 'Suresh Kumar', driverPhone: '+91 91234 56789',
        driverImage: 'https://i.pravatar.cc/200?img=7',
        driverLat: 19.1100, driverLng: 72.8400,
      ),
      Order(
        id: 'ord003', restaurantId: r1.id, restaurantName: r1.name,
        restaurantImage: r1.imageUrl,
        items: [
          OrderItemModel(id: r1.menu[2].id, name: r1.menu[2].name, imageUrl: r1.menu[2].imageUrl, quantity: 1, price: r1.menu[2].price),
        ],
        subtotal: 220, deliveryFee: 29, discount: 0, total: 249,
        status: OrderStatus.cancelled,
        deliveryAddress: const DeliveryAddress(label: 'Home', fullAddress: 'B-204, Andheri West, Mumbai - 400053'),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<FoodItem> _punjabMenu() => [
    const FoodItem(id: 'f101', name: 'Butter Chicken', description: 'Tender chicken in rich tomato-butter gravy',
      imageUrl: 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=300&h=200&fit=crop',
      price: 420, originalPrice: 480, category: 'Main Course', isPopular: true, rating: 4.6, soldCount: 520, restaurantId: 'r1'),
    const FoodItem(id: 'f102', name: 'Dal Makhani', description: 'Slow-cooked black lentils in creamy sauce',
      imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=200&fit=crop',
      price: 280, category: 'Main Course', rating: 4.4, soldCount: 310, restaurantId: 'r1'),
    const FoodItem(id: 'f103', name: 'Tandoori Roti', description: 'Whole wheat bread baked in tandoor',
      imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300&h=200&fit=crop',
      price: 45, category: 'Breads', rating: 4.2, soldCount: 800, restaurantId: 'r1'),
    const FoodItem(id: 'f104', name: 'Paneer Tikka', description: 'Grilled cottage cheese with spices',
      imageUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=300&h=200&fit=crop',
      price: 380, originalPrice: 430, category: 'Starters', isNew: true, rating: 4.5, soldCount: 190, restaurantId: 'r1'),
  ];

  static List<FoodItem> _southMenu() => [
    const FoodItem(id: 'f201', name: 'Masala Dosa', description: 'Crispy dosa with spiced potato filling',
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=300&h=200&fit=crop',
      price: 149, category: 'Dosas', isPopular: true, rating: 4.5, soldCount: 640, restaurantId: 'r2'),
    const FoodItem(id: 'f202', name: 'Idli Sambar', description: '3 soft idlis with sambar and chutneys',
      imageUrl: 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=300&h=200&fit=crop',
      price: 120, category: 'Breakfast', rating: 4.3, soldCount: 420, restaurantId: 'r2'),
    const FoodItem(id: 'f203', name: 'Filter Coffee', description: 'Traditional South Indian filter coffee',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=200&fit=crop',
      price: 79, category: 'Beverages', rating: 4.7, soldCount: 900, restaurantId: 'r2'),
  ];

  static List<FoodItem> _burgerMenu() => [
    const FoodItem(id: 'f301', name: 'Classic Veg Burger', description: 'Aloo tikki patty with fresh veggies',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&h=200&fit=crop',
      price: 169, category: 'Burgers', isPopular: true, rating: 4.2, soldCount: 380, restaurantId: 'r3'),
    const FoodItem(id: 'f302', name: 'Chicken Zinger', description: 'Crispy fried chicken with spicy sauce',
      imageUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=300&h=200&fit=crop',
      price: 229, originalPrice: 269, category: 'Burgers', rating: 4.4, soldCount: 290, restaurantId: 'r3'),
    const FoodItem(id: 'f303', name: 'Loaded Fries', description: 'Crispy fries with cheese and jalapeños',
      imageUrl: 'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=300&h=200&fit=crop',
      price: 149, category: 'Sides', isNew: true, rating: 4.1, soldCount: 210, restaurantId: 'r3'),
  ];

  static List<FoodItem> _pizzaMenu() => [
    const FoodItem(id: 'f401', name: 'Margherita Pizza', description: 'Classic tomato, mozzarella and basil',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300&h=200&fit=crop',
      price: 399, category: 'Pizzas', isPopular: true, rating: 4.5, soldCount: 720, restaurantId: 'r4'),
    const FoodItem(id: 'f402', name: 'Farmhouse Pizza', description: 'Loaded with veggies and herbs',
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=300&h=200&fit=crop',
      price: 499, originalPrice: 579, category: 'Pizzas', rating: 4.3, soldCount: 410, restaurantId: 'r4'),
    const FoodItem(id: 'f403', name: 'Penne Arrabbiata', description: 'Spicy tomato pasta with garlic',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=300&h=200&fit=crop',
      price: 329, category: 'Pasta', rating: 4.2, soldCount: 180, restaurantId: 'r4'),
  ];

  static List<FoodItem> _chineseMenu() => [
    const FoodItem(id: 'f501', name: 'Veg Hakka Noodles', description: 'Stir-fried noodles with veggies',
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300&h=200&fit=crop',
      price: 229, category: 'Noodles', isPopular: true, rating: 4.3, soldCount: 490, restaurantId: 'r5'),
    const FoodItem(id: 'f502', name: 'Chicken Manchurian', description: 'Crispy chicken in tangy Manchurian sauce',
      imageUrl: 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=300&h=200&fit=crop',
      price: 299, category: 'Main Course', rating: 4.4, soldCount: 360, restaurantId: 'r5'),
    const FoodItem(id: 'f503', name: 'Veg Fried Rice', description: 'Wok-tossed rice with fresh vegetables',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=300&h=200&fit=crop',
      price: 219, category: 'Rice', rating: 4.1, soldCount: 280, restaurantId: 'r5'),
  ];
}