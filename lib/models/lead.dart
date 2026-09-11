class Lead {
  final int id;
  final String title;
  final String contactName;
  final String phone;
  final String email;
  final String city;
  final String stage;
  final String notes;
  final double dealValue;

  Lead({
    required this.id,
    required this.title,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.city,
    required this.stage,
    required this.notes,
    required this.dealValue,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unnamed Clinic',
      contactName: json['contact_name'] ?? 'Doctor / Owner',
      phone: (json['phone'] ?? '').toString().trim(),
      email: json['email'] ?? json['email_from'] ?? '',
      city: json['city'] ?? 'Lucknow',
      stage: json['stage'] ?? 'New Lead',
      notes: json['notes'] ?? json['description'] ?? '',
      dealValue: (json['deal_value'] ?? json['expected_revenue'] ?? 40000.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'city': city,
      'stage': stage,
      'notes': notes,
      'deal_value': dealValue,
    };
  }
}
