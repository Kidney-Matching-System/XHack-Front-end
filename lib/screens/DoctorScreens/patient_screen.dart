import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webxhack/utils/constants.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  // Color scheme from previous implementation
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color mediumGray = Color(0xFF64748B);
  static const Color darkGray = Color(0xFF1E293B);

  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrlNest}patient'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          patients = data.map<Map<String, dynamic>>((patient) {
            return {
              'id': patient['_id'],
              'name': 'Patient ${patient['recipientBloodType']}',
              'age': patient['recipientAge'],
              'bloodType': patient['recipientBloodType'],
              'hlaLocus': patient['hlaLocus'],
              'praLevel': patient['praLevel'],
              'urgency': patient['urgency'],
              'isCrossmatchPositive': patient['isCrossmatchPositive'],
              'recipientDiabetes': patient['recipientDiabetes'],
              'previousTransplants': patient['previousTransplants'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load patients: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: Column(
        children: [
          _buildEnhancedHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : patients.isEmpty
                        ? const Center(child: Text('No patients available'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatisticsSection(),
                                const SizedBox(height: 24),
                                const Text(
                                  'All Patients',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkGray,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildPatientsTable(),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Blood Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('HLA Locus', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('PRA Level', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Urgency', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: patients.map((patient) {
            return DataRow(
              cells: [
                DataCell(Text(patient['id'].toString().substring(0, 6))), // Shortened ID
                DataCell(Text(patient['name'])),
                DataCell(Text(patient['age'].toString())),
                DataCell(Text(patient['bloodType'])),
                DataCell(Text(patient['hlaLocus'])),
                DataCell(Text(patient['praLevel'].toString())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(patient['urgency']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getUrgencyColor(patient['urgency']).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      patient['urgency'].toString(),
                      style: TextStyle(
                        color: _getUrgencyColor(patient['urgency']),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: lightBlue),
                    onPressed: () => _showPatientDetails(patient),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: lightBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkGray,
                          ),
                        ),
                        Text(
                          'ID: ${patient['id']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: mediumGray.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Age', patient['age'].toString(), Icons.cake),
              _buildDetailRow('Blood Type', patient['bloodType'], Icons.bloodtype),
              _buildDetailRow('HLA Locus', patient['hlaLocus'], Icons.abc),
              _buildDetailRow('PRA Level', patient['praLevel'].toString(), Icons.health_and_safety),
              _buildDetailRow('Urgency', patient['urgency'].toString(), Icons.warning),
              _buildDetailRow('Crossmatch', patient['isCrossmatchPositive'], Icons.compare),
              _buildDetailRow('Diabetes', patient['recipientDiabetes'], Icons.healing),
              _buildDetailRow('Previous Transplants', patient['previousTransplants'].toString(), Icons.history),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: mediumGray),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(int? urgency) {
  final effectiveUrgency = urgency ?? 0; // Default to 0 if null
  switch (effectiveUrgency) {
    case 1:
      return accentGreen;
    case 2:
      return lightBlue;
    case 3:
      return warningOrange;
    case 4:
      return const Color(0xFFDC2626); // Red for critical
    default:
      return mediumGray;
  }
}

  Widget _buildEnhancedHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: primaryBlue,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patients List',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Doctor Portal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Matching System
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Matching System',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Organs/Patients
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Organs/Patients',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: null, // Current screen
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 153, 245, 176), 
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Patients List',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacerWidth = constraints.maxWidth * 0.2;
                  return SizedBox(width: spacerWidth.clamp(8, 200));
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                  onPressed: () {
                    // Add logout functionality
                  },
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
       _buildStatCard(
  icon: Icons.priority_high,
  title: 'Urgent Cases',
  value: patients.where((p) => (p['urgency'] ?? 0) >= 3).length.toString(),
  subtitle: 'Need immediate attention',
  color: warningOrange,
  gradient: [
    warningOrange.withOpacity(0.1),
    warningOrange.withOpacity(0.05),
  ],
),
        const SizedBox(width: 16),
       
_buildStatCard(
  icon: Icons.priority_high,
  title: 'Urgent Cases',
  value: patients.where((p) => (p['urgency'] ?? 0) >= 3).length.toString(),
  subtitle: 'Need immediate attention',
  color: warningOrange,
  gradient: [
    warningOrange.withOpacity(0.1),
    warningOrange.withOpacity(0.05),
  ],
),







      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required List<Color> gradient,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}