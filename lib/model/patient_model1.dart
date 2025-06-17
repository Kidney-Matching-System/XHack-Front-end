class Patient1 {
  final String id;
  final int recipientAge;
  final String hlaLocus;
  final String recipientBloodType;
  final int praLevel;
  final String? isCrossmatchPositive;
  final String? recipientDiabetes;
  final int? previousTransplants;
  final bool isUsed;
  final String doctor; // Assuming doctor is the ObjectId as string
  final int urgency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient1({
    required this.id,
    required this.recipientAge,
    required this.hlaLocus,
    required this.recipientBloodType,
    required this.praLevel,
    this.isCrossmatchPositive,
    this.recipientDiabetes,
    this.previousTransplants,
    required this.isUsed,
    required this.doctor,
    required this.urgency,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient1.fromJson(Map<String, dynamic> json) => Patient1(
        id: json['_id'],
        recipientAge: json['recipientAge'],
        hlaLocus: json['hlaLocus'],
        recipientBloodType: json['recipientBloodType'],
        praLevel: json['praLevel'],
        isCrossmatchPositive: json['isCrossmatchPositive'],
        recipientDiabetes: json['recipientDiabetes'],
        previousTransplants: json['previousTransplants'],
        isUsed: json['isUsed'] ?? false,
        doctor: json['doctor'] is Map ? json['doctor']['_id'] : json['doctor'],
        urgency: json['urgency'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'recipientAge': recipientAge,
        'hlaLocus': hlaLocus,
        'recipientBloodType': recipientBloodType,
        'praLevel': praLevel,
        if (isCrossmatchPositive != null) 'isCrossmatchPositive': isCrossmatchPositive,
        if (recipientDiabetes != null) 'recipientDiabetes': recipientDiabetes,
        if (previousTransplants != null) 'previousTransplants': previousTransplants,
        'isUsed': isUsed,
        'doctor': doctor,
        'urgency': urgency,
      };
}
