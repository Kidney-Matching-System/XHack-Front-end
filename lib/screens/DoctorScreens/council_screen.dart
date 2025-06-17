import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:webxhack/screens/DoctorScreens/matching_system_screen.dart';
import 'package:webxhack/screens/DoctorScreens/oragn-patients-screen.dart';
import 'package:webxhack/utils/constants.dart';

class MedicalCouncilScreen extends StatefulWidget {
  final String doctorId;
  const MedicalCouncilScreen({super.key, required this.doctorId});

  @override
  State<MedicalCouncilScreen> createState() => _MedicalCouncilScreenState();
}

class _MedicalCouncilScreenState extends State<MedicalCouncilScreen> with TickerProviderStateMixin {
  // Enhanced color scheme
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color mediumGray = Color(0xFF64748B);
  static const Color darkGray = Color(0xFF1E293B);
  
  final String baseUrl = AppConstants.baseUrlNest;
  List<Map<String, dynamic>> _voteRequests = [];
  List<Map<String, dynamic>> _regularRequests = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late IO.Socket socket;
  bool _isSocketConnected = false;
  final Map<String, Function> _requestResultListeners = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
    _initSocket();
  }

@override
void dispose() {
  _requestResultListeners.forEach((requestId, listener) {
    socket.off('/requestresult/$requestId', listener as EventHandler?);
  });
  _requestResultListeners.clear(); // Fix the typo here
  
  socket.disconnect();
  _tabController.dispose();
  super.dispose();
}
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs);
    await prefs.clear();
    if (mounted) {
     /* Navigator.pushReplacementNamed(context, '/login');*/
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
                      'Medical Council',
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardDoctor()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,  
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Organs/Patiens',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 153, 245, 176),
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
                  final spacerWidth = constraints.maxWidth * 0.2;
                  return SizedBox(
                    width: spacerWidth.clamp(8, 200),
                  );
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

  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('No user ID found for socket connection');
      return;
    }

    socket = IO.io(
      AppConstants.baseUrlSocket,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .build(),
    );

    socket.onConnect((_) {
      if (mounted) {
        setState(() => _isSocketConnected = true);
      }
      socket.emit('join', {'userId': userId});
    });

    socket.onDisconnect((_) {
      if (mounted) {
        setState(() => _isSocketConnected = false);
      }
    });

    socket.on('/voterequest/$userId', (data) {
      if (mounted && data is Map) {
        final requestId = data['voteRequestId'];
        setState(() {
          _voteRequests.insert(0, {
            'id': requestId,
            'description': data['description'] ?? 'New vote request',
            'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
            
            'approved': null,
          });
        });
        _addRequestResultListener(requestId);
      }
    });

    

    _fetchData().then((_) {
      for (var request in _voteRequests) {
        _addRequestResultListener(request['id']);
      }
      for (var request in _regularRequests) {
        _addRequestResultListener(request['id']);
      }
    });

    socket.connect();
  }
void _addRequestResultListener(String requestId) {
  if (_requestResultListeners.containsKey(requestId)) return;

  final listener = (resultData) {
    print('Socket update received for request $requestId: $resultData');
    if (mounted && resultData is Map) {
      setState(() {
        final approved = resultData['approved'];
        final closed = resultData['closed'] ?? true; // Assume closed if not specified
        
        // Create new lists to ensure state update is detected
        _voteRequests = [..._voteRequests];
        _regularRequests = [..._regularRequests];
        
        // Update vote requests
        var voteIndex = _voteRequests.indexWhere((v) => v['id'] == requestId);
        if (voteIndex != -1) {
          _voteRequests[voteIndex] = {
            ..._voteRequests[voteIndex],
            'approved': approved,
            'closed': closed
          };
          print('Updated vote request $requestId to approved=$approved');
        }
        
        // Update regular requests
        var regIndex = _regularRequests.indexWhere((r) => r['id'] == requestId);
        if (regIndex != -1) {
          _regularRequests[regIndex] = {
            ..._regularRequests[regIndex],
            'approved': approved,
            'closed': closed
          };
          print('Updated regular request $requestId to approved=$approved');
        } else {
          print('Request ID $requestId not found in regular requests');
        }
      });
    }
  };

  _requestResultListeners[requestId] = listener;
  socket.on('/requestresult/$requestId', listener);
  print('Added listener for request $requestId');
}
 Future<void> _fetchData() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      setState(() {
        _errorMessage = 'No user ID found';
        _isLoading = false;
      });
      return;
    }

    // Fetch vote requests
    final voteResponse = await http.get(
      Uri.parse('${baseUrl}vote-request/$userId'),
    );

    if (voteResponse.statusCode != 200) {
      throw Exception('Failed to load vote requests');
    }

    final voteData = json.decode(voteResponse.body);
    print('Vote Data: $voteData');
    
    _voteRequests = (voteData as List).map<Map<String, dynamic>>((item) {
      return {
        'id': item['_id'],
        'requestId': item['request'],
        'receiver': item['receiver'],
        'description': item['description'] ?? 'No description',
        'decision': item['decision'], // Keep as nullable
        'status': item['status'] ?? false,
        'createdAt': item['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': item['updatedAt'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();

    // Fetch regular requests
    final requestResponse = await http.get(
      Uri.parse('${baseUrl}request/user/$userId'),
    );

    if (requestResponse.statusCode != 200) {
      throw Exception('Failed to load regular requests');
    }

    final requestData = json.decode(requestResponse.body);
    print('Request Data: $requestData');
    
    _regularRequests = (requestData as List).map<Map<String, dynamic>>((item) {
      return {
        'id': item['_id'],
        'userId': item['user'],
        'patientId': item['patient']?['_id'],
        'patientAge': item['patient']?['recipientAge']?.toString() ?? 'N/A',
        'patientBloodType': item['patient']?['recipientBloodType'] ?? 'N/A',
        'urgency': item['urgency']?.toString() ?? 'N/A',
        'numberReceivers': item['number_receivers']?.toString() ?? '0',
        'resultNumber': item['result_number']?.toString() ?? '0',
        'approved': item['approved'] ?? false,
        'closed': item['closed'] ?? false,
        'description': item['description'] ?? 'No description',
        'createdAt': item['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': item['updatedAt'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();

    setState(() {
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
    print('Error fetching data: $e');
  }
}
Widget _buildApprovalIndicator(bool? approved, bool closed) {
  // If request is still open (not closed)
  if (!closed) {
    return Tooltip(
      message: 'Pending decision',
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: warningOrange.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.pending,
          color: warningOrange,
          size: 20,
        ),
      ),
    );
  }
  
  // If request is closed but no explicit decision
  if (approved == null) {
    return Tooltip(
      message: 'Completed without decision',
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: mediumGray.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.help_outline,
          color: mediumGray,
          size: 20,
        ),
      ),
    );
  }
  
  // Request has a decision
  return Tooltip(
    message: approved ? 'Approved' : 'Rejected',
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: approved ? accentGreen.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        approved ? Icons.check_circle : Icons.cancel,
        color: approved ? accentGreen : Colors.red,
        size: 20,
      ),
    ),
  );
}
  Future<void> _handleVoteRequest(String requestId, bool approve) async {
    try {
      final response = await http.patch(
        Uri.parse('${baseUrl}vote-request/$requestId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'decision': approve}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _voteRequests.indexWhere((r) => r['id'] == requestId);
          if (index != -1) {
            _voteRequests[index]['approved'] = approve;
          }
        });
        _showSnackbar(approve ? 'Vote approved' : 'Vote rejected', approve);
      }
    } catch (e) {
      _showSnackbar('Failed to update vote: ${e.toString()}', false);
    }
  }

  Future<void> _handleRegularRequest(String requestId, bool approve) async {
    try {
      final response = await http.patch(
        Uri.parse('${baseUrl}request/$requestId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'approved': approve}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _regularRequests.indexWhere((r) => r['id'] == requestId);
          if (index != -1) {
            _regularRequests[index]['approved'] = approve;
          }
        });
        _showSnackbar(approve ? 'Request approved' : 'Request rejected', approve);
      }
    } catch (e) {
      _showSnackbar('Failed to update request: ${e.toString()}', false);
    }
  }

  void _showSnackbar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? accentGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildVoteRequests() {
    if (_voteRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_vote, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Pending Vote Requests',
              style: TextStyle(color: mediumGray, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'When new council votes are available, they will appear here',
              style: TextStyle(color: mediumGray.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: accentGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _voteRequests.length,
        itemBuilder: (context, index) {
          
          final request = _voteRequests[index];
          print("-------------------------- thsi ssth  request info ---------");
         print(request);

          final approved = request['approved'];
          final createdAt = DateTime.tryParse(request['createdAt']) ?? DateTime.now();
          final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
          //final closed = request['closed'];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          request['description'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildApprovalIndicator(approved,false),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Received: $formattedDate',
                    style: TextStyle(color: mediumGray, fontSize: 12),
                  ),
                  if (approved == null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _handleVoteRequest(request['id'], false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Decline', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _handleVoteRequest(request['id'], true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Accept', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],  
                ],
              ),
            ),
          );
        },
      ),
    );
  }

 Widget _buildRegularRequests() {
  if (_regularRequests.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Regular Requests',
            style: TextStyle(color: mediumGray, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'When new requests are submitted, they will appear here',
            style: TextStyle(color: mediumGray.withOpacity(0.7), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: _fetchData,
    color: accentGreen,
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _regularRequests.length,
      itemBuilder: (context, index) {
        final request = _regularRequests[index];
        final approved = request['approved'];
     final closed = request['closed'];

        final createdAt = DateTime.tryParse(request['createdAt']) ?? DateTime.now();
        final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "patirntName",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: lightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                         
                        ),
                      ],
                    ),
                    _buildApprovalIndicator(approved,closed),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Received: $formattedDate',
                  style: TextStyle(color: mediumGray, fontSize: 12),
                ),
                // Removed the approve/reject buttons section completely
              ],
            ),
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Column(
          children: [
            _buildEnhancedHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = '';
                        });
                        _fetchData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildEnhancedHeader(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: primaryBlue,
              unselectedLabelColor: mediumGray,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3.0,
                  color: accentGreen,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  icon: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_vote, size: 20),
                        SizedBox(width: 8),
                        Text('Council Votes'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  icon: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('My Requests'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVoteRequests(),
                _buildRegularRequests(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
