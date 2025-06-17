import 'package:flutter/material.dart';
import 'package:webxhack/screens/AdminScreens/add_doctor.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Sample data
  final int _availableOrgans = 6;
  final int _waitingPatients = 42;
  final int _possibleMatches = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildEnhancedHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats Section
                  _buildStatsSection(),
                  const SizedBox(height: 30),
                  
                  // Quick Actions Section
                  _buildQuickActionsSection(),
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
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
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
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
                  child: Icon(Icons.admin_panel_settings_rounded, 
                    color: Color(0xFF1E3A8A),
                  size: 26),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'System Overview',
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
                },
                style: TextButton.styleFrom(
                  foregroundColor:const Color.fromARGB(255, 153, 245, 176), 
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddDoctorScreen()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Add Doctor',
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

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'Available Organs',
              value: _availableOrgans,
              icon: Icons.health_and_safety_rounded,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Waiting Patients',
              value: _waitingPatients,
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Possible Matches',
              value: _possibleMatches,
              icon: Icons.connect_without_contact_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSquareActionButton(
                text: 'View All Organs',
                icon: Icons.health_and_safety_rounded,
                onPressed: _showOrgansList,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSquareActionButton(
                text: 'View Patients',
                icon: Icons.people_alt_rounded,
                onPressed: _showPatientsList,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSquareActionButton(
                text: 'Check Records',
                icon: Icons.checklist_rounded,
                onPressed: _checkAllRecords,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSquareActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 100, // Fixed height for square appearance
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Smaller radius for squarer look
          ),
          elevation: 0,
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _checkAllRecords() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Container(
  //         padding: const EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: const BoxDecoration(
  //                 color: Color(0xFFE6F7EE),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: const Icon(
  //                 Icons.check_circle_rounded,
  //                 color: Color(0xFF10B981),
  //                 size: 48,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             const Text(
  //               'All Records Verified',
  //               style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color(0xFF1E293B),
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             const Text(
  //               'All records are unchanged and up to date.',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Color(0xFF64748B),
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF10B981),
  //                   padding: const EdgeInsets.symmetric(vertical: 16),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   'OK',
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
void _checkAllRecords() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F7EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'All Records Verified',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'All records are unchanged and up to date.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  const Text(
                    'Verified by Hedera Hashgraph',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEkGce2yvaLMjiAWbEigCWTXS_6VQ3nI-vKg&s',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),),
                      
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrgansList() {
    // Sample organ data
    final List<Map<String, dynamic>> organs = [
      {'id': 'ORGAN-001', 'type': 'Kidney', 'status': 'Available', 'date': '2023-06-15'},
      {'id': 'ORGAN-002', 'type': 'Kidney', 'status': 'Available', 'date': '2023-06-10'},
      {'id': 'ORGAN-003', 'type': 'Kidney', 'status': 'Matched', 'date': '2023-05-28'},
      {'id': 'ORGAN-004', 'type': 'Kidney', 'status': 'Matched', 'date': '2023-06-10'},
      {'id': 'ORGAN-005', 'type': 'Kidney', 'status': 'Matched', 'date': '2023-06-10'},
      {'id': 'ORGAN-006', 'type': 'Kidney', 'status': 'Matched', 'date': '2023-06-10'},

    ];

    showDialog(
  context: context,
  builder: (context) => _buildListDialog(
    title: 'Available Organs',
    items: organs,
    itemBuilder: (organ) => ListTile(
      leading: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF3B82F6)),
      title: Text(organ['type']),
      subtitle: Row(
        children: [
          Text('Code: ${organ['id']} • Status: '),
          Text(
            organ['status'],
            style: TextStyle(
              color: organ['status'] == 'Matched' ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: Text(organ['date']),
    ),
  ),
);
  }

  void _showPatientsList() {
    // Sample patient data
    final List<Map<String, dynamic>> patients = [
  {'id': 'PATIENT-001', 'name': 'Ghaieth Arbi', 'organ': 'Kidney', 'waitingSince': '2025-01-15'},
  {'id': 'PATIENT-002', 'name': 'Yassine Ajbouni', 'organ': 'Kidney', 'waitingSince': '2025-03-10'},
  {'id': 'PATIENT-003', 'name': 'Houssem Khalfeoui', 'organ': 'Kidney', 'waitingSince': '2025-07-28'},
  {'id': 'PATIENT-004', 'name': 'Amira Ben Salah', 'organ': 'Kidney', 'waitingSince': '2025-02-14'},
  {'id': 'PATIENT-005', 'name': 'Karim Boukadi', 'organ': 'Kidney', 'waitingSince': '2025-04-05'},
  {'id': 'PATIENT-006', 'name': 'Leila Trabelsi', 'organ': 'Kidney', 'waitingSince': '2025-05-22'},
  {'id': 'PATIENT-007', 'name': 'Mohamed Dhiaf', 'organ': 'Kidney', 'waitingSince': '2025-06-18'},
  {'id': 'PATIENT-008', 'name': 'Salma Abid', 'organ': 'Kidney', 'waitingSince': '2025-08-03'},
  {'id': 'PATIENT-009', 'name': 'Omar Slimane', 'organ': 'Kidney', 'waitingSince': '2025-09-11'},
  {'id': 'PATIENT-010', 'name': 'Fatma Zouari', 'organ': 'Kidney', 'waitingSince': '2025-10-29'},
  {'id': 'PATIENT-011', 'name': 'Rami Khemiri', 'organ': 'Kidney', 'waitingSince': '2025-11-07'},
  {'id': 'PATIENT-012', 'name': 'Nour Haddad', 'organ': 'Kidney', 'waitingSince': '2025-12-15'},
  {'id': 'PATIENT-013', 'name': 'Khaled Ben Amor', 'organ': 'Kidney', 'waitingSince': '2026-01-04'},
  {'id': 'PATIENT-014', 'name': 'Siwar Cherif', 'organ': 'Kidney', 'waitingSince': '2026-02-19'},
  {'id': 'PATIENT-015', 'name': 'Aziz Marzouki', 'organ': 'Kidney', 'waitingSince': '2026-03-25'},
  {'id': 'PATIENT-016', 'name': 'Ines Bouazizi', 'organ': 'Kidney', 'waitingSince': '2026-04-30'},
];

    showDialog(
      context: context,
      builder: (context) => _buildListDialog(
        title: 'Waiting Patients',
        items: patients,
        itemBuilder: (patient) => ListTile(
          leading: const Icon(Icons.person_rounded, color: Color(0xFF10B981)),
          title: Text(patient['name']),
          subtitle: Text('Needs: ${patient['organ']}'),
          trailing: Text('Since ${patient['waitingSince']}'),
        ),
      ),
    );
  }

  Widget _buildListDialog({
    required String title,
    required List<Map<String, dynamic>> items,
    required Widget Function(Map<String, dynamic>) itemBuilder,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) => itemBuilder(items[index]),
              ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF1E3A8A),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context); // Close dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

