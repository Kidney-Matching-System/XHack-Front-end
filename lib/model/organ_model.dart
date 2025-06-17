class Organ {
  final String? id;

  final int donorAge;
  final String bloodType;
  final String hlaLocus;
  final int distanceKm;
  String? doctor;
  final int? hlaMatchScore;
  final int? coldIschemiaTimeHr;
  final double? storageTemperatureC;
  final String? preservationFluidType;
  final int? warmIschemiaTimeMin;
  final int? perfusionFlowRateMlMin;
  final int? perfusionPressureMmHg;
  final double? lactateLevelMmolL;
  final int? timeToPerfusionStartMin;
  final bool?isUsed;
factory Organ.fromJson(Map<String, dynamic> json) {
  return Organ(
    id: json['_id'],
    donorAge: json['donor_age'],
    bloodType: json['blood_type'],
    hlaLocus: json['hlaLocus'],
    distanceKm: json['distance_km'],
    doctor: json['doctor'],
    hlaMatchScore: json['hla_match_score'],
    coldIschemiaTimeHr: (json['cold_ischemia_time_hr'] as num?)?.toInt(),
    storageTemperatureC: (json['storage_temperature_C'] as num?)?.toDouble(),
    preservationFluidType: json['preservation_fluid_type'],
    warmIschemiaTimeMin: (json['warm_ischemia_time_min'] as num?)?.toInt(),
    perfusionFlowRateMlMin: (json['perfusion_flow_rate_ml_min'] as num?)?.toInt(),
    perfusionPressureMmHg: (json['perfusion_pressure_mmHg'] as num?)?.toInt(),
    lactateLevelMmolL: (json['lactate_level_mmol_L'] as num?)?.toDouble(),
    timeToPerfusionStartMin: (json['time_to_perfusion_start_min'] as num?)?.toInt(),
    isUsed: (json['isUsed'] as bool?),
  );
}

  Organ({
    this.id,
    required this.donorAge,
    required this.bloodType,
    required this.hlaLocus,
    required this.distanceKm,
    this.doctor,
    this.hlaMatchScore,
    this.coldIschemiaTimeHr,
    this.storageTemperatureC,
    this.preservationFluidType,
    this.warmIschemiaTimeMin,
    this.perfusionFlowRateMlMin,
    this.perfusionPressureMmHg,
    this.lactateLevelMmolL,
    this.timeToPerfusionStartMin,
    this.isUsed,
  });


  Map<String, dynamic> toJson() => {
    'donor_age': donorAge,
    'blood_type': bloodType,
    'hlaLocus': hlaLocus,
    'distance_km': distanceKm,
    
    if (doctor != null) 'doctor': doctor,
    if (hlaMatchScore != null) 'hla_match_score': hlaMatchScore,
    if (coldIschemiaTimeHr != null) 'cold_ischemia_time_hr': coldIschemiaTimeHr,
    if (storageTemperatureC != null) 'storage_temperature_C': storageTemperatureC,
    if (preservationFluidType != null) 'preservation_fluid_type': preservationFluidType,
    if (warmIschemiaTimeMin != null) 'warm_ischemia_time_min': warmIschemiaTimeMin,
    if (perfusionFlowRateMlMin != null) 'perfusion_flow_rate_ml_min': perfusionFlowRateMlMin,
    if (perfusionPressureMmHg != null) 'perfusion_pressure_mmHg': perfusionPressureMmHg,
    if (lactateLevelMmolL != null) 'lactate_level_mmol_L': lactateLevelMmolL,
    if (timeToPerfusionStartMin != null) 'time_to_perfusion_start_min': timeToPerfusionStartMin,
    if (isUsed != null) 'isUsed': isUsed,
  };
}
