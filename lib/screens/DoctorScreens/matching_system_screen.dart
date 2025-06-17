import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webxhack/screens/DoctorScreens/council_screen.dart';
import 'package:webxhack/model/organ_model.dart';
import 'package:webxhack/model/patient_model.dart';
import 'package:webxhack/screens/DoctorScreens/oragn-patients-screen.dart';
import 'package:webxhack/services/match_services.dart';
import 'package:webxhack/services/organ_services.dart';

class OrganMatchingPage extends StatefulWidget {
  const OrganMatchingPage({super.key});

  @override
  State<OrganMatchingPage> createState() => _OrganMatchingPageState();
}

class _OrganMatchingPageState extends State<OrganMatchingPage> {
  // Color scheme from previous implementation
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color mediumGray = Color(0xFF64748B);
  static const Color darkGray = Color(0xFF1E293B);
  List<Organ> availableOrgans = [];
  bool isLoading = true;
  // Sample organ data (kidneys available for donation)
  @override
  void initState() {
    super.initState();
    fetchAvailableOrgans();
  }

  void fetchAvailableOrgans() async {
    try {
      final organs = await OrganService().getAvailableOrgans();
      setState(() {
        availableOrgans = organs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching organs: $e');
    }
  }

  Map<String, List<Patient>> matchedPatients = {};

  Future<void> fetchMatchedPatients(String organId) async {
    try {
      final patients = await MatchService().getPatientsByOrganLastRound(
        organId,
      );
      print("---------------------------------------------");
      print("patients list : ${patients.first.id}");
      print("---------------------------------------------");

      setState(() {
        matchedPatients[organId] = patients;
      });
    } catch (e) {

      print('Error fetching matched patients for $organId: $e');
    }
  }

  // void fetchMatchedPatients(String organId) async {
  //   try {
  //     final matches = await MatchService().getMatchByOrganLastRound(organId);
  //     setState(() {
  //       matchedPatients[organId] = List<Map<String, dynamic>>.from(matches as Iterable);
  //       print('aaasba');
  //       print(matchedPatients);
  //     });
  //   } catch (e) {
  //     print('Error fetching matched patients for $organId: $e');
  //   }
  // }

  void _showMatchingPatientsDialog(BuildContext context, int organIndex) {
    final organ = availableOrgans[organIndex];
    final patients = matchedPatients[organ.id] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Matching Patients for Organ ${organ.id} | Blood: ${organ.bloodType}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Data Table
                SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Cin',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Age',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Blood',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Priority',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Organ HLA',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Ischemia Time (hr)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Distance (km)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows:
                          patients.map((patient) {
                            return DataRow(
                              onSelectChanged: (_) {
                                _showPatientDetailsDialog(
                                  context,
                                  patient,
                                  organ,
                                );
                              },
                              cells: [
                                DataCell(
                                  Text(
                                    patient.isUsed
                                        ? (patient.cin != null &&
                                                patient.cin!
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty
                                            ? patient.cin!.toString()
                                            : '12345678')
                                        : 'Unknown cin',
                                  ),
                                ), // <-- this is the missing 1st cell
                                DataCell(Text(patient.recipientAge.toString())),
                                DataCell(Text(patient.recipientBloodType)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                        patient.urgency.toString(),
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getPriorityColor(
                                          patient.urgency.toString(),
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      patient.urgency.toString(),
                                      style: TextStyle(
                                        color: _getPriorityColor(
                                          patient.urgency.toString(),
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(organ.hlaLocus ?? 'N/A')),
                                DataCell(
                                  Text('${organ.coldIschemiaTimeHr ?? 'N/A'}'),
                                ),
                                DataCell(Text('${organ.distanceKm ?? 'N/A'}')),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),

                // Close Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: mediumGray,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPatientDetailsDialog(
    BuildContext context,
    Patient patient,
    Organ organ,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            'https://cdn-icons-png.flaticon.com/512/2922/2922506.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Patient: unkown", //${patient['name']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("Organ ID", organ.id ?? "N/A"),
                          _buildDetailRow(
                            "Donor Age",
                            organ.donorAge.toString(),
                          ),
                          _buildDetailRow("Blood Type", organ.bloodType),
                          _buildDetailRow(
                            "Distance (km)",
                            organ.distanceKm.toStringAsFixed(1),
                          ),

                          const Divider(),
                          // _buildDetailRow("Patient Name", patient['name']),
                          _buildDetailRow(
                            "Age",
                            patient.recipientAge.toString(),
                          ),
                          _buildDetailRow(
                            "Blood Type",
                            patient.recipientBloodType,
                          ),
                          // _buildDetailRow(
                          //   "Waiting Time",
                          //   patient['waitingTime'],
                          // ),
                          _buildDetailRow(
                            "Priority",
                            patient.urgency.toString(),
                          ),
                          _buildDetailRow("Location", "unkown"),
                          const SizedBox(height: 20),
                          const Text(
                            "Compatibility Analysis:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _buildDetailRow("Blood Type Match", "Perfect Match"),
                          _buildDetailRow("Distance", "250 km"),
                          _buildDetailRow("Success Probability", "92%"),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: mediumGray,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Back'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            _showSurgeryConfirmationDialog(
                              context,
                              patient,
                              organ,
                            );
                          },
                          child: const Text('Schedule Surgery'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSurgeryConfirmationDialog(
    BuildContext context,
    Patient patient,
    Organ organ,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Confirm Surgery",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Confirm surgery for unkown ",
                      ), //${patient['name']}?"),
                      const SizedBox(height: 8),
                      Text(
                        "Organ: ${organ.id ?? "N/A"} (${organ.bloodType})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "This action cannot be undone.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: mediumGray,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _scheduleSurgery(patient, organ);
                          Navigator.of(context).pop();
                          _showKnowenPatientDetailsDialog(
                            context,
                            patient,
                            organ,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Surgery scheduled for patient name', //${patient['name']}',
                              ),
                              backgroundColor: accentGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scheduleSurgery(Patient patient, Organ organ) async {
    final result = await MatchService().submitMatch(organ.id!, patient.id!);

    print('Surgery scheduled:');
    //print('Patient: ${patient['name']}');
    print('Organ: ${organ.id}');
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: mediumGray,
              ),
            ),
          ),
          const Text(": "),
          Expanded(child: Text(value, style: const TextStyle(color: darkGray))),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return const Color(0xFFDC2626);
      case 'high':
        return warningOrange;
      case 'medium':
        return lightBlue;
      case 'low':
        return accentGreen;
      default:
        return mediumGray;
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatisticsSection(),
                  const SizedBox(height: 24),
                  const Text(
                    'Available Kidneys for Matching',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: availableOrgans.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        // onTap:
                        //     () => _showMatchingPatientsDialog(context, index),
                        onTap: () async {
                          final organId = availableOrgans[index].id;
                          if (organId != null) {
                            await fetchMatchedPatients(organId);
                            _showMatchingPatientsDialog(context, index);
                          }
                        },

                        child: Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Container
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Container(
                                  height: 100,
                                  width: double.infinity,
                                  color: lightBlue.withOpacity(0.1),
                                  child: Image.network(
                                    'https://med.stanford.edu/news/all-news/2014/06/adult-kidneys-constantly-grow/_jcr_content/_cq_featuredimage.coreimg.jpg/1745379238460/lksc.jpg',
                                    width: double.infinity,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Organ Info
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   /* Text(
                                      availableOrgans[index].id ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: darkGray,
                                      ),
                                    ),*/
                                    const SizedBox(height: 4),
                                    Text(
                                      'Blood: ${availableOrgans[index].bloodType}',
                                      style: TextStyle(
                                        color: mediumGray,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Show matches',
                                          style: TextStyle(
                                            color: lightBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: lightBlue,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                      'Organ Matching System',
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
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => OrganMatchingPage()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 153, 245, 176),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Matching System',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardDoctor()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Organs/Patiens',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MedicalCouncilScreen(doctorId: '',)));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Medical council',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacerWidth =
                      constraints.maxWidth * 0.2; // 20% of available width
                  return SizedBox(
                    width: spacerWidth.clamp(8, 200),
                  ); // Min 100, max 200
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
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
          icon: Icons.medical_services_rounded,
          title: 'Available Kidneys',
          value: availableOrgans.length.toString(),
          subtitle: 'Ready for matching',
          color: accentGreen,
          gradient: [
            accentGreen.withOpacity(0.1),
            accentGreen.withOpacity(0.05),
          ],
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.health_and_safety,
          title: 'Potential Operations',
          value: '${availableOrgans.length * 5}',
          subtitle: 'Possible matches',
          color: lightBlue,
          gradient: [lightBlue.withOpacity(0.1), lightBlue.withOpacity(0.05)],
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

  void _showKnowenPatientDetailsDialog(
    BuildContext context,
    Patient patient,
    Organ organ,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            'https://cdn-icons-png.flaticon.com/512/2922/2922506.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Patient:",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("Patient", patient.cin.toString()),
                          _buildDetailRow("Organ ID", organ.id ?? "N/A"),
                          _buildDetailRow(
                            "Donor Age",
                            organ.donorAge.toString(),
                          ),
                          _buildDetailRow("Blood Type", organ.bloodType),
                          _buildDetailRow(
                            "Distance (km)",
                            organ.distanceKm.toStringAsFixed(1),
                          ),

                          const Divider(),
                          // _buildDetailRow("Patient Name", patient['name']),
                          _buildDetailRow(
                            "Age",
                            patient.recipientAge.toString(),
                          ),
                          _buildDetailRow(
                            "Blood Type",
                            patient.recipientBloodType,
                          ),
                          // _buildDetailRow(
                          //   "Waiting Time",
                          //   patient['waitingTime'],
                          // ),
                          _buildDetailRow(
                            "Priority",
                            patient.urgency.toString(),
                          ),
                          _buildDetailRow("Location", "unkown"),
                          const SizedBox(height: 20),
                          const Text(
                            "Compatibility Analysis:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _buildDetailRow("Blood Type Match", "Perfect Match"),
                          _buildDetailRow("Distance", "250 km"),
                          _buildDetailRow("Success Probability", "92%"),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              "NB: this match will be removed from the available system matches",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}





//--------------------------------JUST FOR TEST
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:webxhack/screens/DoctorScreens/council_screen.dart';
// import 'package:webxhack/model/organ_model.dart';
// import 'package:webxhack/model/patient_model.dart';
// import 'package:webxhack/screens/DoctorScreens/oragn-patients-screen.dart';
// import 'package:webxhack/services/match_services.dart';
// import 'package:webxhack/services/organ_services.dart';

// class OrganMatchingPage extends StatefulWidget {
//   const OrganMatchingPage({super.key});

//   @override
//   State<OrganMatchingPage> createState() => _OrganMatchingPageState();
// }

// class _OrganMatchingPageState extends State<OrganMatchingPage> {
//   // Color scheme from previous implementation
//   static const Color primaryBlue = Color(0xFF1E3A8A);
//   static const Color lightBlue = Color(0xFF3B82F6);
//   static const Color accentGreen = Color(0xFF10B981);
//   static const Color warningOrange = Color(0xFFF59E0B);
//   static const Color lightGray = Color(0xFFF8FAFC);
//   static const Color mediumGray = Color(0xFF64748B);
//   static const Color darkGray = Color(0xFF1E293B);
//   List<Organ> availableOrgans = [];
//   bool isLoading = true;

//   // Sample patient data
//   final List<Map<String, dynamic>> matchedPatients = [
//     {'id': 'PATIENT-001', 'name': 'Ghaieth Arbi', 'organ': 'Kidney', 'waitingSince': '2025-01-15'},
//     {'id': 'PATIENT-002', 'name': 'Yassine Ajbouni', 'organ': 'Kidney', 'waitingSince': '2025-03-10'},
//     {'id': 'PATIENT-003', 'name': 'Houssem Khalfeoui', 'organ': 'Kidney', 'waitingSince': '2025-07-28'},
//     {'id': 'PATIENT-004', 'name': 'Amira Ben Salah', 'organ': 'Kidney', 'waitingSince': '2025-02-14'},
//     {'id': 'PATIENT-005', 'name': 'Karim Boukadi', 'organ': 'Kidney', 'waitingSince': '2025-04-05'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchAvailableOrgans();
//   }

//   void fetchAvailableOrgans() async {
//     try {
//       final organs = await OrganService().getAvailableOrgans();
//       setState(() {
//         availableOrgans = organs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching organs: $e');
//     }
//   }

//   void _showMatchingPatientsDialog(BuildContext context, int organIndex) {
//     final organ = availableOrgans[organIndex];

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: primaryBlue,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.medical_services,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Matching Patients for Organ ${organ.id} | Blood: ${organ.bloodType}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Data Table
//                 SizedBox(
//                   width: double.maxFinite,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       showCheckboxColumn: false,
//                       columns: const [
//                         DataColumn(
//                           label: Text(
//                             'ID',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         // DataColumn(
//                         //   label: Text(
//                         //     'Name',
//                         //     style: TextStyle(fontWeight: FontWeight.bold),
//                         //   ),
//                         // ),
//                         DataColumn(
//                           label: Text(
//                             'Organ Needed',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         DataColumn(
//                           label: Text(
//                             'Waiting Since',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                       rows: matchedPatients.map((patient) {
//                         return DataRow(
//                           onSelectChanged: (_) {
//                             _showPatientDetailsDialog(
//                               context,
//                               patient,
//                               organ,
//                             );
//                           },
//                           cells: [
//                             DataCell(Text(patient['id'])),
//                             // DataCell(Text(patient['name'])),
//                             DataCell(Text(patient['organ'])),
//                             DataCell(Text(patient['waitingSince'])),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),

//                 // Close Button
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         style: TextButton.styleFrom(
//                           foregroundColor: mediumGray,
//                         ),
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Close'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showPatientDetailsDialog(
//     BuildContext context,
//     Map<String, dynamic> patient,
//     Organ organ,
//   ) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * 0.7,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: primaryBlue,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(16),
//                         topRight: Radius.circular(16),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Image.network(
//                             'https://cdn-icons-png.flaticon.com/512/2922/2922506.png',
//                             width: 40,
//                             height: 40,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           "Patient: ${patient['name']}",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildDetailRow("Organ ID", organ.id ?? "N/A"),
//                           _buildDetailRow(
//                             "Blood Type",
//                             organ.bloodType,
//                           ),
//                           const Divider(),
//                           _buildDetailRow("Patient ID", patient['id']),
//                           _buildDetailRow("Patient Name", patient['name']),
//                           _buildDetailRow("Organ Needed", patient['organ']),
//                           _buildDetailRow("Waiting Since", patient['waitingSince']),
//                           const SizedBox(height: 20),
//                           const Text(
//                             "Compatibility Analysis:",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           _buildDetailRow("Blood Type Match", "Perfect Match"),
//                           _buildDetailRow("Success Probability", "92%"),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           style: TextButton.styleFrom(
//                             foregroundColor: mediumGray,
//                           ),
//                           onPressed: () => Navigator.of(context).pop(),
//                           child: const Text('Back'),
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: accentGreen,
//                             foregroundColor: Colors.white,
//                           ),
//                           onPressed: () async {
//                             Navigator.of(context).pop();
//                             _showSurgeryConfirmationDialog(
//                               context,
//                               patient,
//                               organ,
//                             );
//                           },
//                           child: const Text('Schedule Surgery'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showSurgeryConfirmationDialog(
//     BuildContext context,
//     Map<String, dynamic> patient,
//     Organ organ,
//   ) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: primaryBlue,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.medical_services,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         "Confirm Surgery",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Confirm surgery for ${patient['name']}",
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Organ: ${organ.id ?? "N/A"} (${organ.bloodType})",
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         "This action cannot be undone.",
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         style: TextButton.styleFrom(
//                           foregroundColor: mediumGray,
//                         ),
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Cancel'),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: accentGreen,
//                           foregroundColor: Colors.white,
//                         ),
//                         onPressed: () {
//                           // In a real app, you would call your service here
//                           Navigator.of(context).pop();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 'Surgery scheduled for ${patient['name']}',
//                               ),
//                               backgroundColor: accentGreen,
//                               behavior: SnackBarBehavior.floating,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               duration: const Duration(seconds: 3),
//                             ),
//                           );
//                         },
//                         child: const Text('Confirm'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: mediumGray,
//               ),
//             ),
//           ),
//           const Text(": "),
//           Expanded(child: Text(value, style: const TextStyle(color: darkGray))),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: lightGray,
//       body: Column(
//         children: [
//           _buildEnhancedHeader(),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildStatisticsSection(),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Available Kidneys for Matching',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: darkGray,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 5,
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                           childAspectRatio: 1.2,
//                         ),
//                     itemCount: availableOrgans.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () => _showMatchingPatientsDialog(context, index),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Image Container
//                               ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(
//                                   top: Radius.circular(12),
//                                 ),
//                                 child: Container(
//                                   height: 100,
//                                   width: double.infinity,
//                                   color: lightBlue.withOpacity(0.1),
//                                   child: Image.network(
//                                     'https://med.stanford.edu/news/all-news/2014/06/adult-kidneys-constantly-grow/_jcr_content/_cq_featuredimage.coreimg.jpg/1745379238460/lksc.jpg',
//                                     width: double.infinity,
//                                     height: 40,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               // Organ Info
//                               Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       availableOrgans[index].id ?? 'N/A',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: darkGray,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Blood: ${availableOrgans[index].bloodType}',
//                                       style: TextStyle(
//                                         color: mediumGray,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           'Show matches',
//                                           style: TextStyle(
//                                             color: lightBlue,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Icon(
//                                           Icons.arrow_forward_rounded,
//                                           size: 14,
//                                           color: lightBlue,
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedHeader() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [primaryBlue, lightBlue],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.3),
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: const CircleAvatar(
//                   radius: 22,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.medical_services_rounded,
//                     color: primaryBlue,
//                     size: 26,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Organ Matching System',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'Doctor Portal',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white.withOpacity(0.8),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   //Navigator.push(context, MaterialPageRoute(builder: (context) => OrganMatchingPage()));
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: const Color.fromARGB(255, 153, 245, 176),
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                 ),
//                 child: const Text(
//                   'Matching System',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => DashboardDoctor()),
//                   );
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                 ),
//                 child: const Text(
//                   'Organs/Patiens',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => MedicalCouncilScreen(doctorId: '',)));
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                 ),
//                 child: const Text(
//                   'Medical council',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final spacerWidth =
//                       constraints.maxWidth * 0.2; // 20% of available width
//                   return SizedBox(
//                     width: spacerWidth.clamp(8, 200),
//                   ); // Min 100, max 200
//                 },
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.white.withOpacity(0.2)),
//                 ),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.logout_rounded,
//                     color: Colors.white,
//                     size: 22,
//                   ),
//                   onPressed: () {
//                     // Add logout functionality
//                   },
//                   tooltip: 'Logout',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatisticsSection() {
//     return Row(
//       children: [
//         _buildStatCard(
//           icon: Icons.medical_services_rounded,
//           title: 'Available Kidneys',
//           value: availableOrgans.length.toString(),
//           subtitle: 'Ready for matching',
//           color: accentGreen,
//           gradient: [
//             accentGreen.withOpacity(0.1),
//             accentGreen.withOpacity(0.05),
//           ],
//         ),
//         const SizedBox(width: 16),
//         _buildStatCard(
//           icon: Icons.health_and_safety,
//           title: 'Potential Operations',
//           value: '${availableOrgans.length * 5}',
//           subtitle: 'Possible matches',
//           color: lightBlue,
//           gradient: [lightBlue.withOpacity(0.1), lightBlue.withOpacity(0.05)],
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     required String subtitle,
//     required Color color,
//     required List<Color> gradient,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradient,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.white, width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: color, size: 20),
//                 ),
//                 const Spacer(),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: darkGray,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: mediumGray,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }