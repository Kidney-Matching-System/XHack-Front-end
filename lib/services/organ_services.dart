import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webxhack/model/organ_model.dart';
import 'package:webxhack/utils/constants.dart';

class OrganService {
  final String baseUrl = '${AppConstants.baseUrlNest}organ'; // Replace with your actual backend URL



  Future<List<Organ>> getAllOrgans() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200||response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Organ.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load organs');
    }
  }

  Future<List<Organ>> getAvailableOrgans() async {
    final response = await http.get(Uri.parse('$baseUrl'));
    print(response.body);
    if (response.statusCode == 200||response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Organ.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load unused organs');
    }
  }

  Future<Organ> getOrganById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl$id'));

    if (response.statusCode == 200) {
      return Organ.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Organ not found');
    }
  }

  Future<Organ> createOrgan(Organ organ) async {
    organ.doctor="684caa9ab4609586aa9ec996";
    final response = await http.post(
      // Uri.parse(baseUrl),
      Uri.parse('{$baseUrl}add-organ'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(organ.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Organ.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      throw Exception('Failed to create organ');
    }
  }

  Future<Organ> updateOrgan(String id, Organ organ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(organ.toJson()),
    );

    if (response.statusCode == 200) {
      return Organ.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update organ');
    }
  }

  Future<void> deleteOrgan(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete organ');
    }
  }
}
