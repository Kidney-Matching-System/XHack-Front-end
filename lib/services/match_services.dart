import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webxhack/model/patient_model.dart';
import 'package:webxhack/utils/constants.dart';
import 'package:webxhack/model/match_model.dart';

class MatchService {
  final String baseUrl = AppConstants.baseUrlNest;

  /// Create a new match
  Future<Match> createMatch(Map<String, dynamic> matchData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/match'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(matchData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Match.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create match: ${response.body}');
    }
  }

  /// Get all matches
  Future<List<Match>> getAllMatches() async {
    final response = await http.get(Uri.parse('$baseUrl/match'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch matches');
    }
  }

  /// Get a match by ID
  Future<Match> getMatchById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/match/$id'));

    if (response.statusCode == 200) {
      return Match.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Match not found');
    }
  }

  /// Update a match by ID
  Future<Match> updateMatch(String id, Map<String, dynamic> updateData) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/match/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      return Match.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update match');
    }
  }

  /// Delete a match
  Future<void> deleteMatch(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/match/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete match');
    }
  }

  Future<List<Patient>> getPatientsByOrganLastRound(String organId) async {
  final response = await http.get(
    Uri.parse('${baseUrl}match/by-organ-last-round/$organId'),
  );
  print("response body from patients by organ: ${response.body}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body) as List;
    final patients = data.map((e) => Patient.fromJson(e)).toList();

    print("______________________________");
    print("patients parsed: $patients");
    print("______________________________");

    return patients;
  } else {
    throw Exception('No patients found for this organ in the last round');
  }
}


 /// Submit a match by organ and patient
Future<Match> submitMatch(String organId, String patientId) async {
  final response = await http.patch(
    Uri.parse('${baseUrl}match/submit/$organId/$patientId'),
  );

  if (response.statusCode == 200||response.statusCode == 201) {
    return Match.fromJson(jsonDecode(response.body));
  } else {
    print("response submit : ${response.body}");
    throw Exception('Failed to submit match');
  }
}

}
