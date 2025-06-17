class VoteRequest {
  final String id;
  final String requestId;
  final String receiverId;
  final bool? decision;
  final String description;
  final DateTime createdAt;

  VoteRequest({
    required this.id,
    required this.requestId,
    required this.receiverId,
    this.decision,
    required this.description,
    required this.createdAt,
  });

  factory VoteRequest.fromJson(Map<String, dynamic> json) {
    return VoteRequest(
      id: json['_id'],
      requestId: json['request'],
      receiverId: json['receiver'],
      decision: json['decision'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class PatientRequest {
  final String id;
  final String userId;
  final Patient patient;
  final int numberReceivers;
  final int resultNumber;
  final int urgency;
  final bool approved;
  final String description;
  final DateTime createdAt;

  PatientRequest({
    required this.id,
    required this.userId,
    required this.patient,
    required this.numberReceivers,
    required this.resultNumber,
    required this.urgency,
    required this.approved,
    required this.description,
    required this.createdAt,
  });

  factory PatientRequest.fromJson(Map<String, dynamic> json) {
    return PatientRequest(
      id: json['_id'],
      userId: json['user'],
      patient: Patient.fromJson(json['patient']),
      numberReceivers: json['number_receivers'],
      resultNumber: json['result_number'],
      urgency: json['urgency'],
      approved: json['approved'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Patient {
  final String id;
  final int recipientAge;
  final String hlaLocus;
  final String recipientBloodType;
  final int praLevel;
  final String isCrossmatchPositive;
  final String recipientDiabetes;
  final int previousTransplants;
  final bool isUsed;
  final String doctorId;
  final int urgency;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.recipientAge,
    required this.hlaLocus,
    required this.recipientBloodType,
    required this.praLevel,
    required this.isCrossmatchPositive,
    required this.recipientDiabetes,
    required this.previousTransplants,
    required this.isUsed,
    required this.doctorId,
    required this.urgency,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'],
      recipientAge: json['recipientAge'],
      hlaLocus: json['hlaLocus'],
      recipientBloodType: json['recipientBloodType'],
      praLevel: json['praLevel'],
      isCrossmatchPositive: json['isCrossmatchPositive'],
      recipientDiabetes: json['recipientDiabetes'],
      previousTransplants: json['previousTransplants'],
      isUsed: json['isUsed'],
      doctorId: json['doctor'],
      urgency: json['urgency'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}