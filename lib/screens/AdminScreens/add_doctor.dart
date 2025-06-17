import 'package:flutter/material.dart';
import 'package:webxhack/screens/AdminScreens/admin_dashboard.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final List<Map<String, dynamic>> _doctors = [
  {
    'id': 'DOC-001',
    'name': 'Dr. Ahmad Hassan',
    'specialization': 'Kidney Transplant Surgeon',
    'email': 'a.hassan@hospital.com',
    'phone': '+216 12 345 678',
  },
  {
    'id': 'DOC-002',
    'name': 'Dr. Mohamed Ali',
    'specialization': 'Nephrologist',
    'email': 'm.ali@hospital.com',
    'phone': '+216 98 765 432',
  },
  {
    'id': 'DOC-003',
    'name': 'Dr. Samira Ben Omer',
    'specialization': 'Transplant Anesthesiologist',
    'email': 's.benomer@hospital.com',
    'phone': '+216 21 987 654',
  },
  {
    'id': 'DOC-004',
    'name': 'Dr. Khaled El Hadi',
    'specialization': 'Transplant Immunologist',
    'email': 'k.elhadi@hospital.com',
    'phone': '+216 54 321 987',
  },
  {
    'id': 'DOC-005',
    'name': 'Dr. Fatma Zahra',
    'specialization': 'Transplant Nurse Coordinator',
    'email': 'f.zahra@hospital.com',
    'phone': '+216 76 543 210',
  },
  {
    'id': 'DOC-006',
    'name': 'Dr. Youssef El Kasmii',
    'specialization': 'Transplant Radiologist',
    'email': 'y.elkasmii@hospital.com',
    'phone': '+216 34 567 890',
  },
  {
    'id': 'DOC-007',
    'name': 'Dr. Leila Trabelsi',
    'specialization': 'Transplant Psychologist',
    'email': 'l.trabelsi@hospital.com',
    'phone': '+216 45 678 901',
  },
  {
    'id': 'DOC-008',
    'name': 'Dr. Omar Slimane',
    'specialization': 'Transplant Infectious Disease Specialist',
    'email': 'o.slimane@hospital.com',
    'phone': '+216 67 890 123',
  },
];


  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _currentDoctorId;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildEnhancedHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDoctorsList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDoctorDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
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
                      'Doctors Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Add/Edit Doctors',
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
                  foregroundColor:Colors.white, 
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
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 153, 245, 176), 
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

  Widget _buildDoctorsList() {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _doctors.isEmpty
              ? const Center(
                  child: Text(
                    'No doctors found. Add a new doctor to get started.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEFF6FF),
                          child: Icon(
                            Icons.medical_services_rounded,
                            color: Color(0xFF3B82F6)),
                        ),
                        title: Text(
                          doctor['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor['specialization']),
                            const SizedBox(height: 4),
                            Text(
                              '${doctor['email']} • ${doctor['phone']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 20),
                              color: const Color(0xFF3B82F6),
                              onPressed: () => _showEditDoctorDialog(doctor),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, size: 20),
                              color: const Color(0xFFEF4444),
                              onPressed: () => _deleteDoctor(doctor['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showAddDoctorDialog() {
    _currentDoctorId = null;
    _isEditing = false;
    _clearForm();

    showDialog(
      context: context,
      builder: (context) => _buildDoctorFormDialog(),
    );
  }

  void _showEditDoctorDialog(Map<String, dynamic> doctor) {
    _currentDoctorId = doctor['id'];
    _isEditing = true;
    _nameController.text = doctor['name'];
    _specializationController.text = doctor['specialization'];
    _emailController.text = doctor['email'];
    _phoneController.text = doctor['phone'];

    showDialog(
      context: context,
      builder: (context) => _buildDoctorFormDialog(),
    );
  }

  Widget _buildDoctorFormDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Doctor' : 'Add New Doctor',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter doctor name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.medical_services_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter specialization' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => !value!.contains('@') ? 'Please enter valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveDoctor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isEditing ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveDoctor() {
    if (_formKey.currentState!.validate()) {
      final newDoctor = {
        'id': _currentDoctorId ?? 'DOC-${DateTime.now().millisecondsSinceEpoch}',
        'name': _nameController.text,
        'specialization': _specializationController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      setState(() {
        if (_isEditing) {
          final index = _doctors.indexWhere((doc) => doc['id'] == _currentDoctorId);
          if (index != -1) _doctors[index] = newDoctor;
        } else {
          _doctors.add(newDoctor);
        }
      });

      Navigator.pop(context);
      _clearForm();
    }
  }

  void _deleteDoctor(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: const Text('Are you sure you want to delete this doctor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _doctors.removeWhere((doc) => doc['id'] == id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _specializationController.clear();
    _emailController.clear();
    _phoneController.clear();
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
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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


