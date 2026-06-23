// lib/models/app_models.dart

// ─── Category ────────────────────────────────────────────────────────────────
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final String route;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.route,
  });
}

// ─── Banner ───────────────────────────────────────────────────────────────────

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String targetRoute;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.targetRoute,
  });
}

// ─── Food Option ──────────────────────────────────────────────────────────────

class FoodOptionItem {
  final String name;
  final double extraPrice;
  bool isSelected;

  FoodOptionItem({
    required this.name,
    this.extraPrice = 0,
    this.isSelected = false,
  });
}

class FoodOptionGroup {
  final String name;
  final List<FoodOptionItem> items;
  final bool isRequired;
  final bool isMultiple;

  FoodOptionGroup({
    required this.name,
    required this.items,
    this.isRequired = false,
    this.isMultiple = false,
  });
}

// ─── Food Item ────────────────────────────────────────────────────────────────

class FoodItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double originalPrice;
  final String category;
  final bool isPopular;
  final bool isNew;
  final double rating;
  final int soldCount;
  final String restaurantId;
  final List<FoodOptionGroup> options;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.originalPrice = 0,
    required this.category,
    this.isPopular = false,
    this.isNew = false,
    this.rating = 0,
    this.soldCount = 0,
    required this.restaurantId,
    this.options = const [],
  });

  bool get hasDiscount => originalPrice > 0 && originalPrice > price;
  double get discountPct =>
      hasDiscount ? ((originalPrice - price) / originalPrice) * 100 : 0;
}

// ─── Restaurant ───────────────────────────────────────────────────────────────

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String coverUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double deliveryFee;
  final double minOrder;
  final String distance;
  final bool isOpen;
  final bool isFavorite;
  final List<String> categories;
  final String address;
  final double lat;
  final double lng;
  final List<FoodItem> menu;
  final List<String> tags;
  final String description;

  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.coverUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrder,
    required this.distance,
    required this.isOpen,
    this.isFavorite = false,
    required this.categories,
    required this.address,
    required this.lat,
    required this.lng,
    required this.menu,
    required this.tags,
    this.description = '',
  });

  Restaurant copyWith({bool? isFavorite}) => Restaurant(
        id: id,
        name: name,
        imageUrl: imageUrl,
        coverUrl: coverUrl,
        rating: rating,
        reviewCount: reviewCount,
        deliveryTime: deliveryTime,
        deliveryFee: deliveryFee,
        minOrder: minOrder,
        distance: distance,
        isOpen: isOpen,
        isFavorite: isFavorite ?? this.isFavorite,
        categories: categories,
        address: address,
        lat: lat,
        lng: lng,
        menu: menu,
        tags: tags,
        description: description,
      );
}

// ─── Cart Item ────────────────────────────────────────────────────────────────

class CartItem {
  final FoodItem food;
  int quantity;
  final List<FoodOptionItem> selectedOptions;
  final String note;

  CartItem({
    required this.food,
    this.quantity = 1,
    this.selectedOptions = const [],
    this.note = '',
  });

  double get totalPrice {
    final extra =
        selectedOptions.fold<double>(0, (s, o) => s + o.extraPrice);
    return (food.price + extra) * quantity;
  }
}

// ─── Delivery Address ─────────────────────────────────────────────────────────

class DeliveryAddress {
  final String label;
  final String fullAddress;
  final double lat;
  final double lng;

  const DeliveryAddress({
    required this.label,
    required this.fullAddress,
    this.lat = 0,
    this.lng = 0,
  });
}

// ─── User Role ────────────────────────────────────────────────────────────────

enum UserRole { customer, restaurantAdmin, driver, superAdmin }

// ─── Order Status ─────────────────────────────────────────────────────────────

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
  pending,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:     return 'Order Placed';
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.preparing:  return 'Preparing';
      case OrderStatus.pickedUp:   return 'Picked Up';
      case OrderStatus.onTheWay:   return 'On the Way';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  bool get isActive => [
        OrderStatus.placed,
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.pickedUp,
        OrderStatus.onTheWay,
      ].contains(this);
}

// ─── Payment ──────────────────────────────────────────────────────────────────

enum PaymentMethod { cash, upi, card, wallet, netBanking }

enum PaymentStatus { pending, paid, failed, refunded }

// ─── Order Item ───────────────────────────────────────────────────────────────

class OrderItemModel {
  final String id;
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;
  final bool isVeg;
  final String? customisation;

  const OrderItemModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
    required this.quantity,
    required this.price,
    this.isVeg = true,
    this.customisation,
  });

  double get total => price * quantity;
}

// ─── Order ────────────────────────────────────────────────────────────────────

class Order {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double platformFee;
  final double taxes;
  final double discount;
  final String? couponCode;
  final double total;
  final OrderStatus status;
  final DeliveryAddress deliveryAddress;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? driverName;
  final String? driverPhone;
  final String? driverImage;
  final double? driverLat;
  final double? driverLng;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? otp;

  Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.platformFee = 0,
    this.taxes = 0,
    this.discount = 0,
    this.couponCode,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedDelivery,
    this.driverName,
    this.driverPhone,
    this.driverImage,
    this.driverLat,
    this.driverLng,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    this.otp,
  });

  String get statusLabel => status.label;
  bool get isActive      => status.isActive;

  Order copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? driverName,
    String? driverPhone,
    String? driverImage,
    double? driverLat,
    double? driverLng,
  }) => Order(
        id: id,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        restaurantImage: restaurantImage,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        platformFee: platformFee,
        taxes: taxes,
        discount: discount,
        couponCode: couponCode,
        total: total,
        status: status ?? this.status,
        deliveryAddress: deliveryAddress,
        createdAt: createdAt,
        estimatedDelivery: estimatedDelivery,
        driverName: driverName ?? this.driverName,
        driverPhone: driverPhone ?? this.driverPhone,
        driverImage: driverImage ?? this.driverImage,
        driverLat: driverLat ?? this.driverLat,
        driverLng: driverLng ?? this.driverLng,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        otp: otp,
      );
}

// ─── User ─────────────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profileImageUrl;
  final double walletBalance;
  final int points;
  final String defaultAddress;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImageUrl,
    this.walletBalance = 0,
    this.points = 0,
    this.defaultAddress = '',
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? profileImageUrl,
    double? walletBalance,
    int? points,
    String? defaultAddress,
  }) =>
      AppUser(
        id: id,
        name: name ?? this.name,
        phone: phone,
        email: email ?? this.email,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        walletBalance: walletBalance ?? this.walletBalance,
        points: points ?? this.points,
        defaultAddress: defaultAddress ?? this.defaultAddress,
      );
}

// ─── Address Type & Model ─────────────────────────────────────────────────────

enum AddressType { home, work, other }

class AddressModel {
  final String id;
  final AddressType type;
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final double lat;
  final double lng;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.type,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.lat = 0,
    this.lng = 0,
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = [line1, if (line2 != null) line2!, city, state, pincode];
    return parts.join(', ');
  }

  AddressModel copyWith({bool? isDefault}) => AddressModel(
        id: id,
        type: type,
        label: label,
        line1: line1,
        line2: line2,
        city: city,
        state: state,
        pincode: pincode,
        lat: lat,
        lng: lng,
        isDefault: isDefault ?? this.isDefault,
      );
}