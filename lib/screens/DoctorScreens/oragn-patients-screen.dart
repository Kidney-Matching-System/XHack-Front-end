import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webxhack/model/organ_model.dart';
import 'package:webxhack/model/patient_model.dart';
import 'package:webxhack/screens/DoctorScreens/council_screen.dart';
import 'package:webxhack/screens/DoctorScreens/matching_system_screen.dart';
import 'package:webxhack/services/organ_services.dart';
import 'package:webxhack/services/patient_services.dart';
import 'package:webxhack/utils/constants.dart';
import 'package:http/http.dart' as http;

class DashboardDoctor extends StatefulWidget {
  const DashboardDoctor({super.key, this.onSearchChanged});

  final ValueChanged<String>? onSearchChanged;

  @override
  State<DashboardDoctor> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<DashboardDoctor>
    with TickerProviderStateMixin {
  // Add these new variables at the top of your state class with other variables
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _donorAgeController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _hlaLocusController = TextEditingController();
  final TextEditingController _coldIschemiaTimeController =
      TextEditingController();
  final TextEditingController _storageTempController = TextEditingController();
  final TextEditingController _preservationFluidController =
      TextEditingController();
  final TextEditingController _warmIschemiaTimeController =
      TextEditingController();
  final TextEditingController _perfusionFlowRateController =
      TextEditingController();
  final TextEditingController _perfusionPressureController =
      TextEditingController();
  final TextEditingController _lactateLevelController = TextEditingController();
  final TextEditingController _timeToPerfusionStartController =
      TextEditingController();
  final TextEditingController _distanceKmController = TextEditingController();
  final _hla1Controller = TextEditingController();
  final _hla2Controller = TextEditingController();
  final _hla3Controller = TextEditingController();
  final TextEditingController _hla1PatientController = TextEditingController();
  final TextEditingController _hla2PatientController = TextEditingController();
  final TextEditingController _hla3PatientController = TextEditingController();

  final _cinController = TextEditingController();
  final _recipientAgeController = TextEditingController();
  final _hlaLocusControllerP = TextEditingController();
  final _recipientBloodTypeController = TextEditingController();
  final _praLevelController = TextEditingController();
  final _crossmatchController = TextEditingController();
  final _diabetesController = TextEditingController();
  final _previousTransplantsController = TextEditingController();
  final _urgencyController = TextEditingController();
  final _nameController = TextEditingController();

  bool _showSearch = false;

  int _currentTabIndex = 0;
  bool _showLists = true;
  late AnimationController _toggleAnimationController;
  late Animation<double> _toggleAnimation;

  // Enhanced color scheme
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color mediumGray = Color(0xFF64748B);
  static const Color darkGray = Color(0xFF1E293B);

  List<Organ> _organs = [];
  bool _isLoading = true;

  List<Patient> _patients = [];

  void _loadPatients() async {
    try {
      final patients = await PatientService().getAllPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() => _isLoading = false);
    }
  }

  // Form controllers
  final TextEditingController _organIdController = TextEditingController();
  final TextEditingController _organTypeController = TextEditingController();
  final TextEditingController _organBloodTypeController =
      TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientBloodTypeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrgans();
    _loadPatients();

    _toggleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _toggleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _fetchOrgans() async {
    try {
      final organs = await OrganService().getAllOrgans();
      setState(() {
        _organs = organs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching organs: $e')));
    }
  }

  @override
  void dispose() {
    _hla1Controller.dispose();
    _hla2Controller.dispose();
    _hla3Controller.dispose();
    _toggleAnimationController.dispose();
    _organIdController.dispose();
    _organTypeController.dispose();
    _organBloodTypeController.dispose();
    _patientNameController.dispose();
    _patientBloodTypeController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    _cinController.dispose();
    _recipientAgeController.dispose();
    _hlaLocusControllerP.dispose();
    _recipientBloodTypeController.dispose();
    _praLevelController.dispose();
    _crossmatchController.dispose();
    _diabetesController.dispose();
    _previousTransplantsController.dispose();
    _urgencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildEnhancedHeader(),
            Column(
              children: [
                _buildStatisticsSection(),
                _buildNavigationSection(),
                _showLists ? _buildListView() : _buildFormView(),
              ],
            ),
          ],
        ),
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
                    Text(
                      _showLists
                          ? 'Medical Dashboard'
                          : 'Add ${_currentTabIndex == 0 ? 'Organ' : 'Patient'}',
                      style: const TextStyle(
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
              // New TextButton added here
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrganMatchingPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Matching System',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardDoctor()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 153, 245, 176),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Organs/Patiens',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
              //const SizedBox(width: 8),
              // Right side - Responsive spacer
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
                  onPressed: _logout,
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
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.medical_services_rounded,
            title: 'Available Organs',
            value: _organs.where((o) => o.isUsed == false).length.toString(),
            subtitle:
                '${_organs.where((o) => o.isUsed == true).length} Reserved',
            color: accentGreen,
            gradient: [
              accentGreen.withOpacity(0.1),
              accentGreen.withOpacity(0.05),
            ],
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.people_rounded,
            title: 'Waiting Patients',
            value: _patients.length.toString(),
            subtitle:
                '${_patients.where((p) => p.urgency == 'Critical').length} Critical',
            color: warningOrange,
            gradient: [
              warningOrange.withOpacity(0.1),
              warningOrange.withOpacity(0.05),
            ],
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
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

  Widget _buildNavigationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(children: [_buildToggleButton(), const Spacer()]),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTabButton(
                'Organ Management',
                Icons.medical_services_rounded,
                0,
              ),
              const SizedBox(width: 12),
              _buildTabButton('Patient Registry', Icons.people_rounded, 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Row(
      mainAxisSize: MainAxisSize.min, // Makes the row take minimum space
      children: [
        // Your existing toggle button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors:
                      _showLists
                          ? [accentGreen, accentGreen.withOpacity(0.8)]
                          : [lightBlue, lightBlue.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    _showLists = !_showLists;
                    if (_showLists) {
                      _toggleAnimationController.reverse();
                    } else {
                      _toggleAnimationController.forward();
                      _clearForms();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _showLists
                              ? Icons.add_circle_rounded
                              : Icons.list_alt_rounded,
                          color: Colors.white,
                          size: 20,
                          key: ValueKey(_showLists),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _showLists
                            ? 'Add New ${_currentTabIndex == 0 ? 'Organ' : 'Patient'}'
                            : 'View ${_currentTabIndex == 0 ? 'Organs' : 'Patients'} List',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10), // Spacing between toggle and search button
        // Search button (now outside the toggle button)
        Material(
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (_showSearch) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _focusNode.requestFocus();
                  });
                } else {
                  _searchController.clear();
                  if (widget.onSearchChanged != null) {
                    widget.onSearchChanged!('');
                  }
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _showSearch ? Icons.close : Icons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
  /*
  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: _showLists 
                  ? [accentGreen, accentGreen.withOpacity(0.8)]
                  : [lightBlue, lightBlue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _showLists = !_showLists;
                if (_showLists) {
                  _toggleAnimationController.reverse();
                } else {
                  _toggleAnimationController.forward();
                  _clearForms();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _showLists ? Icons.add_circle_rounded : Icons.list_alt_rounded,
                      color: Colors.white,
                      size: 20,
                      key: ValueKey(_showLists),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _showLists ? 'Add New ${_currentTabIndex == 0 ? 'Organ' : 'Patient'}' : 'View ${_currentTabIndex == 0 ? 'Organs' : 'Patients'} List',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }*/

  Widget _buildTabButton(String title, IconData icon, int index) {
    final isActive = _currentTabIndex == index;
    return Expanded(
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: isActive ? 4 : 0,
        shadowColor: primaryBlue.withOpacity(0.3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive ? primaryBlue : Colors.white,
            border: Border.all(
              color: isActive ? primaryBlue : Colors.grey[300]!,
              width: isActive ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _currentTabIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isActive ? Colors.white : mediumGray,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive ? Colors.white : darkGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: _currentTabIndex == 0 ? _buildOrganList() : _buildPatientList(),
    );
  }

  Widget _buildOrganList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _organs.length,
      itemBuilder: (context, index) {
        final organ = _organs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getOrganColor(organ.bloodType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getOrganIcon(organ.bloodType),
                size: 24,
                color: _getOrganColor(organ.bloodType),
              ),
            ),
            title: Text(
              '${organ.coldIschemiaTimeHr} ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: darkGray,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bloodtype_rounded,
                        size: 16,
                        color: mediumGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        organ.bloodType,
                        style: TextStyle(
                          color: mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: mediumGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        organ.distanceKm.toString(),
                        style: TextStyle(
                          color: mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor("No").withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(
                    organ.isUsed.toString(),
                  ).withOpacity(0.3),
                ),
              ),
              child: Text(
                organ.isUsed.toString(),
                style: TextStyle(
                  color: _getStatusColor(organ.isUsed.toString()),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap:
                () => _showOrganDetails(context, organ as Map<String, dynamic>),
          ),
        );
      },
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _patients.length,
      itemBuilder: (context, index) {
        final patient = _patients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPriorityColor(
                  patient.urgency.toString(),
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 24,
                color: _getPriorityColor(patient.urgency.toString()),
              ),
            ),
            title: Text(
              patient.name ?? "Patient ${patient.recipientBloodType}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: darkGray,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bloodtype_rounded,
                        size: 16,
                        color: mediumGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        patient.recipientBloodType,
                        style: TextStyle(
                          color: mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.medical_services_rounded,
                        size: 16,
                        color: mediumGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "kidney",
                        style: TextStyle(
                          color: mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Waiting since ${patient.urgency}',
                    style: TextStyle(color: mediumGray, fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPriorityColor(
                  patient.urgency.toString(),
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getPriorityColor(
                    patient.urgency.toString(),
                  ).withOpacity(0.3),
                ),
              ),
              child: Text(
                patient.urgency.toString(),
                style: TextStyle(
                  color: _getPriorityColor(patient.urgency.toString()),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showPatientDetails(context, patient as Patient),
          ),
        );
      },
    );
  }

  void _submitPatientForm() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final patient = Patient(
        name: _nameController.text.trim(),
        recipientAge: int.parse(_recipientAgeController.text),
        hlaLocus:
            '${_hla1PatientController.text.trim()},${_hla2PatientController.text.trim()},${_hla3PatientController.text.trim()}',
        recipientBloodType: _recipientBloodTypeController.text.trim(),
        praLevel: int.parse(_praLevelController.text),
        isCrossmatchPositive:
            _crossmatchController.text.trim().isNotEmpty
                ? _crossmatchController.text.trim()
                : null,
        recipientDiabetes:
            _diabetesController.text.trim().isNotEmpty
                ? _diabetesController.text.trim()
                : null,
        previousTransplants:
            _previousTransplantsController.text.isNotEmpty
                ? int.parse(_previousTransplantsController.text)
                : null,
        urgency: int.parse(_urgencyController.text),
        doctor: userId, // Replace with dynamic value if needed
        cin:
            _cinController.text.trim().isNotEmpty
                ? _cinController.text.trim()
                : null,
        isUsed: false,
      );

      final createdPatient = await PatientService().createPatient(patient);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient ${createdPatient.id} created successfully!'),
        ),
      );

      // Optional: clear form or navigate
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _submitOrganForm() async {
    try {
      final organ = Organ(
        donorAge: int.parse(_donorAgeController.text),
        bloodType: _bloodTypeController.text.trim(),
        hlaLocus:
            '${_hla1Controller.text.trim()},${_hla2Controller.text.trim()},${_hla3Controller.text.trim()}',
        distanceKm: int.parse(_distanceKmController.text),
        //doctor: _doctorIdController.text.trim(),
        coldIschemiaTimeHr:
            _coldIschemiaTimeController.text.isNotEmpty
                ? int.parse(_coldIschemiaTimeController.text)
                : null,
        storageTemperatureC:
            _storageTempController.text.isNotEmpty
                ? double.parse(_storageTempController.text)
                : null,
        preservationFluidType:
            _preservationFluidController.text.trim().isNotEmpty
                ? _preservationFluidController.text.trim()
                : null,
        warmIschemiaTimeMin:
            _warmIschemiaTimeController.text.isNotEmpty
                ? int.parse(_warmIschemiaTimeController.text)
                : null,
        perfusionFlowRateMlMin:
            _perfusionFlowRateController.text.isNotEmpty
                ? int.parse(_perfusionFlowRateController.text)
                : null,
        perfusionPressureMmHg:
            _perfusionPressureController.text.isNotEmpty
                ? int.parse(_perfusionPressureController.text)
                : null,
        lactateLevelMmolL:
            _lactateLevelController.text.isNotEmpty
                ? double.parse(_lactateLevelController.text)
                : null,
        timeToPerfusionStartMin:
            _timeToPerfusionStartController.text.isNotEmpty
                ? int.parse(_timeToPerfusionStartController.text)
                : null,
      );

      final createdOrgan = await OrganService().createOrgan(organ);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Organ ${createdOrgan.id} created successfully!'),
        ),
      );

      // Optionally: clear form or navigate
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Widget _buildFormView() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _currentTabIndex == 0
                          ? Icons.medical_services_rounded
                          : Icons.person_add_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New ${_currentTabIndex == 0 ? 'Organ' : 'Patient'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                      ),
                      Text(
                        'Fill in the required information below',
                        style: TextStyle(
                          fontSize: 14,
                          color: mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _currentTabIndex == 0 ? _buildOrganForm() : _buildPatientForm(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _currentTabIndex == 0
                          ? _submitOrganForm
                          : _submitPatientForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: primaryBlue.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Save Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _donorAgeController,
          label: 'Donor Age',
          icon: Icons.person,
          hint: 'e.g., 32',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _bloodTypeController,
          label: 'Blood Type',
          icon: Icons.bloodtype,
          hint: 'e.g., O, A, B, AB',
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HLA Locus',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hla1Controller,
                      decoration: const InputDecoration(
                        hintText: 'e.g., A2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _hla2Controller,
                      decoration: const InputDecoration(
                        hintText: 'e.g., B7',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _hla3Controller,
                      decoration: const InputDecoration(
                        hintText: 'e.g., DR15',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildFormField(
          controller: _coldIschemiaTimeController,
          label: 'Cold Ischemia Time (hr)',
          icon: Icons.ac_unit,
          hint: 'e.g., 4',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _storageTempController,
          label: 'Storage Temp (°C)',
          icon: Icons.thermostat_rounded,
          hint: 'e.g., 4.0',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _preservationFluidController,
          label: 'Preservation Fluid Type',
          icon: Icons.science,
          hint: 'e.g., UW, HTK',
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _warmIschemiaTimeController,
          label: 'Warm Ischemia Time (min)',
          icon: Icons.local_fire_department,
          hint: 'e.g., 30',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _perfusionFlowRateController,
          label: 'Perfusion Flow Rate (ml/min)',
          icon: Icons.speed,
          hint: 'e.g., 150',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _perfusionPressureController,
          label: 'Perfusion Pressure (mmHg)',
          icon: Icons.compress,
          hint: 'e.g., 60',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _lactateLevelController,
          label: 'Lactate Level (mmol/L)',
          icon: Icons.analytics_outlined,
          hint: 'e.g., 2.3',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _timeToPerfusionStartController,
          label: 'Time to Perfusion Start (min)',
          icon: Icons.timer_outlined,
          hint: 'e.g., 45',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _distanceKmController,
          label: 'Distance (km)',
          icon: Icons.route_outlined,
          hint: 'e.g., 50',
          inputType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPatientForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person,
          hint: 'e.g., Foulen BenFoulen',
          inputType: TextInputType.name,
        ),
        _buildFormField(
          controller: _cinController,
          label: 'CIN',
          icon: Icons.badge,
          hint: 'e.g., 12345678',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _recipientAgeController,
          label: 'Age',
          icon: Icons.cake,
          hint: 'e.g., 45',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HLA Locus',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hla1PatientController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., A2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _hla2PatientController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., B7',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _hla3PatientController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., DR15',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildFormField(
          controller: _recipientBloodTypeController,
          label: 'Blood Type',
          icon: Icons.bloodtype_rounded,
          hint: 'e.g., O, A, B, AB',
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _praLevelController,
          label: 'PRA Level (%)',
          icon: Icons.bar_chart,
          hint: 'e.g., 30',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _crossmatchController,
          label: 'Crossmatch Positive (Yes/No)',
          icon: Icons.check_circle_outline,
          hint: 'Yes or No',
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _diabetesController,
          label: 'Diabetes (Yes/No)',
          icon: Icons.medical_services_outlined,
          hint: 'Yes or No',
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _previousTransplantsController,
          label: 'Previous Transplants',
          icon: Icons.history,
          hint: 'e.g., 2',
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          controller: _urgencyController,
          label: 'Urgency Level (1-5)',
          icon: Icons.priority_high,
          hint: '1 = High priority, 5 = Low',
          inputType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType inputType = TextInputType.text, // Add this with default
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: mediumGray.withOpacity(0.7)),
            prefixIcon: Icon(icon, color: primaryBlue, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: lightGray,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Color _getOrganColor(String type) {
    switch (type.toLowerCase()) {
      case 'kidney':
        return const Color(0xFF8B5CF6);
      case 'liver':
        return const Color(0xFFF59E0B);
      case 'heart':
        return const Color(0xFFEF4444);
      case 'lung':
        return const Color(0xFF06B6D4);
      default:
        return primaryBlue;
    }
  }

  IconData _getOrganIcon(String type) {
    switch (type.toLowerCase()) {
      case 'kidney':
        return Icons.water_drop_rounded;
      case 'liver':
        return Icons.restaurant_rounded;
      case 'heart':
        return Icons.favorite_rounded;
      case 'lung':
        return Icons.air_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return accentGreen;
      case 'reserved':
        return warningOrange;
      case 'in transit':
        return lightBlue;
      default:
        return mediumGray;
    }
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

  void _clearForms() {
    _organIdController.clear();
    _organTypeController.clear();
    _organBloodTypeController.clear();
    _patientNameController.clear();
    _patientBloodTypeController.clear();
  }

  void _saveForm() {
    if (_currentTabIndex == 0) {
      if (_organIdController.text.isEmpty ||
          _organTypeController.text.isEmpty ||
          _organBloodTypeController.text.isEmpty) {
        _showSnackBar('Please fill all fields', isError: true);
        return;
      }

      final newOrgan = {
        'id': _organIdController.text,
        'type': _organTypeController.text,
        'bloodType': _organBloodTypeController.text,
        'status': 'Available',
        'donor': 'Anonymous',
        'location': 'OR-${_organs.length + 1}',
      };
      setState(() {
        _organs.add(newOrgan as Organ);
        _showLists = true;
      });
      _showSnackBar('Organ added successfully', isError: false);
      _clearForms();
    } else {
      if (_patientNameController.text.isEmpty ||
          _patientBloodTypeController.text.isEmpty) {
        _showSnackBar('Please fill all fields', isError: true);
        return;
      }

      final newPatient = {
        'id': 'PAT-${(_patients.length + 1).toString().padLeft(3, '0')}',
        'name': _patientNameController.text,
        'bloodType': _patientBloodTypeController.text,
        'waitingSince': DateTime.now().toString().split(' ')[0],
        'priority': 'Medium',
        'organNeeded': 'Kidney',
      };
      setState(() {
        _patients.add(newPatient as Patient);
        _showLists = true;
      });
      _showSnackBar('Patient added successfully', isError: false);
      _clearForms();
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFDC2626) : accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showOrganDetails(BuildContext context, Map<String, dynamic> organ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getOrganColor(organ['type']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getOrganIcon(organ['type']),
                          color: _getOrganColor(organ['type']),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organ Details',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkGray,
                              ),
                            ),
                            Text(
                              organ['id'],
                              style: TextStyle(
                                fontSize: 14,
                                color: mediumGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    'Type',
                    organ['type'],
                    Icons.medical_services_rounded,
                  ),
                  _buildDetailRow(
                    'Blood Type',
                    organ['bloodType'],
                    Icons.bloodtype_rounded,
                  ),
                  _buildDetailRow(
                    'Status',
                    organ['status'],
                    Icons.info_rounded,
                  ),
                  _buildDetailRow(
                    'Location',
                    organ['location'],
                    Icons.location_on_rounded,
                  ),
                  _buildDetailRow(
                    'Donor',
                    organ['donor'],
                    Icons.person_rounded,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Edit functionality would go here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showPatientDetails(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            patient.urgency.toString(),
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: _getPriorityColor(patient.urgency.toString()),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient Details',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkGray,
                              ),
                            ),
                            Text(
                              "Patient ${patient.recipientBloodType}",
                              style: TextStyle(
                                fontSize: 14,
                                color: mediumGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    'Patient ID',
                    patient.id.toString(),
                    Icons.badge_rounded,
                  ),
                  _buildDetailRow(
                    'Blood Type',
                    patient.recipientBloodType,
                    Icons.bloodtype_rounded,
                  ),
                  _buildDetailRow(
                    'Organ Needed',
                    "kidney",
                    Icons.medical_services_rounded,
                  ),
                  _buildDetailRow(
                    'Priority',
                    patient.urgency.toString(),
                    Icons.priority_high_rounded,
                  ),
                  _buildDetailRow(
                    'Waiting Since',
                    patient.urgency.toString(),
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Edit functionality would go here
                            _showEditUrgencyDialog(context, patient);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showEditUrgencyDialog(BuildContext context, Patient patient) async {
    final TextEditingController _urgencyController = TextEditingController(
      text: patient.urgency?.toString() ?? '',
    );
    final TextEditingController _descriptionController = TextEditingController();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Urgency Level"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _urgencyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Urgency (1 - highest, 5 - lowest)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description (optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? newUrgency = int.tryParse(_urgencyController.text);
                final String? description = _descriptionController.text.trim();

                if (newUrgency != null && newUrgency >= 1 && newUrgency <= 5) {
                  try {
                    final response = await http.post(
                      Uri.parse('${AppConstants.baseUrlNest}request'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        "userId": userId,
                        "patientId": patient.id,
                        "urgency": newUrgency,
                        if (description!.isNotEmpty) "description": description,
                      }),
                    );

                    if (response.statusCode != 201 &&
                        response.statusCode != 200) {
                      throw Exception(
                        "Urgency update request failed: ${response.body}",
                      );
                    }

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Urgency update request sent successfully."),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Urgency must be a number between 1 and 5."),
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: mediumGray),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: darkGray,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: mediumGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
