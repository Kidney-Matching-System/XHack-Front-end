import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webxhack/utils/constants.dart';
import '../model/patient_model.dart';

class PatientService {
  final String baseUrl = AppConstants.baseUrlNest;

  Future<List<Patient>> getAllPatients() async {
    final response = await http.get(Uri.parse('${baseUrl}patient'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Patient.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }

  Future<Patient> getPatientById(String id) async {
    final response = await http.get(Uri.parse('${baseUrl}patient/$id'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Patient.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Patient not found');
    }
  }

  Future<Patient> createPatient(Patient patient) async {
    print("create patient : ${patient.toJson()}");
    final response = await http.post(
      Uri.parse('${baseUrl}patient/add-patient'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(patient.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    } else {
      print("create patien : ${response.body}");
      throw Exception('Failed to create patient');
    }
  }

  Future<Patient> updatePatient(String id, Patient patient) async {
    final response = await http.patch(
      //Uri.parse('${baseUrl}patient/$id'),
      Uri.parse('${baseUrl}update-patient/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(patient.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Patient.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update patient');
    }
  }

  Future<void> deletePatient(String id) async {
    final response = await http.delete(Uri.parse('${baseUrl}patient/$id'));

    if (response.statusCode != 200 || response.statusCode == 201) {
      throw Exception('Failed to delete patient');
    }
  }
}
