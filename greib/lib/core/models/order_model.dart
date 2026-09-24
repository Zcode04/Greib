class Order {
  final String id;
  final String userId;
  final String serviceType;
  final String status;
  final String description;
  final double price;
  final String? agentId;
  final DateTime? createdAt;
  final String pickupLocation;
  final String deliveryLocation;

  const Order({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.status,
    required this.description,
    required this.price,
    this.agentId,
    this.createdAt,
    required this.pickupLocation,
    required this.deliveryLocation,
  });
}
