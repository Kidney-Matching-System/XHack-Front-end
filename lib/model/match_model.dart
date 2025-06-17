import 'organ_model.dart';
import 'patient_model.dart';

class Match {
  final String? id;
  final double matchScore;
  final String patientId;
  final String organId;
  final int round;
  final bool isUsed;

  // Optional: full nested patient and organ objects if populated
  final Organ? organ;
  final Patient? patient;

  Match({
    this.id,
    required this.matchScore,
    required this.patientId,
    required this.organId,
    required this.round,
    this.isUsed = false,
    this.organ,
    this.patient,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['_id'],
      matchScore: json['matchScore'].toDouble(),
      patientId: json['patient'] is Map
          ? json['patient']['_id']
          : json['patient'],
      organId: json['organ'] is Map
          ? json['organ']['_id']
          : json['organ'],
      round: json['round'],
      isUsed: json['isUsed'] ?? false,
      organ: json['organ'] is Map ? Organ.fromJson(json['organ']) : null,
      patient: json['patient'] is Map ? Patient.fromJson(json['patient']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchScore': matchScore,
      'patient': patientId,
      'organ': organId,
      'round': round,
      'isUsed': isUsed,
    };
  }
}
