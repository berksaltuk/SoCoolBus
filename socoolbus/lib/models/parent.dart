class Parent {
  final String name;
  final String phone;
  String address;
  String addressDirections;

  Parent({
    required this.name,
    required this.phone,
    required this.address,
    required this.addressDirections,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
        name: json['name'],
        phone: json['phone'],
        address: json['address'],
        addressDirections: json['addressDirections']);
  }
}
