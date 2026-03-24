import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const GPAPredictorApp());
}

class GPAPredictorApp extends StatelessWidget {
  const GPAPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student GPA Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GPAPredictorScreen(),
    );
  }
}

class GPAPredictorScreen extends StatefulWidget {
  const GPAPredictorScreen({super.key});

  @override
  State<GPAPredictorScreen> createState() => _GPAPredictorScreenState();
}

class _GPAPredictorScreenState extends State<GPAPredictorScreen> {
  final _formKey = GlobalKey<FormState>();

  static const String _apiUrl =
      'https://linear-regression-model-riws.onrender.com/predict';

  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _parentalEducationController = TextEditingController();
  final _studyTimeController = TextEditingController();
  final _absencesController = TextEditingController();
  final _tutoringController = TextEditingController();
  final _parentalSupportController = TextEditingController();
  final _extracurricularController = TextEditingController();
  final _sportsController = TextEditingController();
  final _musicController = TextEditingController();
  final _volunteeringController = TextEditingController();

  String _result = '';
  String _resultGpa = '';
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    _ethnicityController.dispose();
    _parentalEducationController.dispose();
    _studyTimeController.dispose();
    _absencesController.dispose();
    _tutoringController.dispose();
    _parentalSupportController.dispose();
    _extracurricularController.dispose();
    _sportsController.dispose();
    _musicController.dispose();
    _volunteeringController.dispose();
    super.dispose();
  }

  Future<void> _predictGPA() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _result = '';
      _resultGpa = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'Age': int.parse(_ageController.text),
          'Gender': int.parse(_genderController.text),
          'Ethnicity': int.parse(_ethnicityController.text),
          'ParentalEducation': int.parse(_parentalEducationController.text),
          'StudyTimeWeekly': double.parse(_studyTimeController.text),
          'Absences': int.parse(_absencesController.text),
          'Tutoring': int.parse(_tutoringController.text),
          'ParentalSupport': int.parse(_parentalSupportController.text),
          'Extracurricular': int.parse(_extracurricularController.text),
          'Sports': int.parse(_sportsController.text),
          'Music': int.parse(_musicController.text),
          'Volunteering': int.parse(_volunteeringController.text),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _resultGpa = data['predicted_gpa'].toString();
          _result = _getGpaMessage(double.parse(_resultGpa));
          _hasError = false;
        });
      } else {
        setState(() {
          _result = 'Error: ${data['detail'] ?? 'Invalid input'}';
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Connection Error.\nPlease check your internet.';
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGpaMessage(double gpa) {
    if (gpa >= 3.5) return 'Excellent Performance!';
    if (gpa >= 3.0) return 'Good Standing';
    if (gpa >= 2.5) return 'Average Performance';
    if (gpa >= 2.0) return 'Below Average';
    return 'Needs Improvement';
  }

  Color _getGpaColor(double gpa) {
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.lightGreen;
    if (gpa >= 2.5) return Colors.orange;
    if (gpa >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _ageController.clear();
    _genderController.clear();
    _ethnicityController.clear();
    _parentalEducationController.clear();
    _studyTimeController.clear();
    _absencesController.clear();
    _tutoringController.clear();
    _parentalSupportController.clear();
    _extracurricularController.clear();
    _sportsController.clear();
    _musicController.clear();
    _volunteeringController.clear();
    setState(() {
      _result = '';
      _resultGpa = '';
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'GPA Predictor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildSectionHeader(
                      icon: Icons.person,
                      title: 'Demographics',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _ageController,
                      label: 'Age',
                      hint: 'Enter age (13-21)',
                      icon: Icons.cake,
                    ),
                    _buildDropdownField(
                      controller: _genderController,
                      label: 'Gender',
                      icon: Icons.face,
                      options: {'0': 'Male', '1': 'Female'},
                    ),
                    _buildDropdownField(
                      controller: _ethnicityController,
                      label: 'Ethnicity',
                      icon: Icons.groups,
                      options: {
                        '0': 'Black African',
                        '1': 'Caucasian',
                        '2': 'Asian',
                        '3': 'Other',
                      },
                    ),
                    _buildDropdownField(
                      controller: _parentalEducationController,
                      label: 'Parental Education',
                      icon: Icons.school,
                      options: {
                        '0': 'None',
                        '1': 'High School',
                        '2': 'Some College',
                        '3': 'Bachelor\'s',
                        '4': 'Graduate',
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader(
                      icon: Icons.menu_book,
                      title: 'Academic Performance',
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _studyTimeController,
                      label: 'Study Time (hrs/week)',
                      hint: 'Hours of study (0-20)',
                      icon: Icons.access_time,
                      isDecimal: true,
                    ),
                    _buildInputField(
                      controller: _absencesController,
                      label: 'Absences',
                      hint: 'Number of absences (0-30)',
                      icon: Icons.event_busy,
                    ),
                    _buildDropdownField(
                      controller: _tutoringController,
                      label: 'Receiving Tutoring',
                      icon: Icons.support_agent,
                      options: {'0': 'No', '1': 'Yes'},
                    ),
                    _buildDropdownField(
                      controller: _parentalSupportController,
                      label: 'Parental Support',
                      icon: Icons.family_restroom,
                      options: {
                        '0': 'None',
                        '1': 'Low',
                        '2': 'Medium',
                        '3': 'High',
                        '4': 'Very High',
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader(
                      icon: Icons.sports_esports,
                      title: 'Extracurricular Activities',
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      controller: _extracurricularController,
                      label: 'Extracurricular',
                      icon: Icons.groups,
                      options: {'0': 'No', '1': 'Yes'},
                    ),
                    _buildDropdownField(
                      controller: _sportsController,
                      label: 'Sports',
                      icon: Icons.sports_soccer,
                      options: {'0': 'No', '1': 'Yes'},
                    ),
                    _buildDropdownField(
                      controller: _musicController,
                      label: 'Music',
                      icon: Icons.music_note,
                      options: {'0': 'No', '1': 'Yes'},
                    ),
                    _buildDropdownField(
                      controller: _volunteeringController,
                      label: 'Volunteering',
                      icon: Icons.volunteer_activism,
                      options: {'0': 'No', '1': 'Yes'},
                    ),
                    const SizedBox(height: 24),
                    _buildButtons(),
                    const SizedBox(height: 20),
                    if (_result.isNotEmpty) _buildResultCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ML-Powered Prediction',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Predict GPA based on behavioral,\ndemographic & socioeconomic factors',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isDecimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isDecimal) {
            final num = double.tryParse(value);
            if (num == null) return 'Invalid number';
          } else {
            final num = int.tryParse(value);
            if (num == null) return 'Invalid integer';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Map<String, String> options,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: options.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (value) {
          controller.text = value ?? '';
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF4A90D9)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90D9).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _predictGPA,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.calculate),
              label: Text(_isLoading ? 'Predicting...' : 'Predict GPA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final gpa = double.tryParse(_resultGpa) ?? 0;
    final gpaColor = _getGpaColor(gpa);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _hasError
              ? [Colors.red.shade50, Colors.red.shade100]
              : [gpaColor.withOpacity(0.1), gpaColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _hasError ? Colors.red : gpaColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_hasError ? Colors.red : gpaColor).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _hasError ? Icons.error_outline : Icons.check_circle_outline,
            size: 48,
            color: _hasError ? Colors.red : gpaColor,
          ),
          const SizedBox(height: 16),
          if (_resultGpa.isNotEmpty && !_hasError) ...[
            Text(
              'Predicted GPA',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _resultGpa,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: gpaColor,
              ),
            ),
            Text(
              'out of 4.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: gpaColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _result,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: gpaColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Based on behavioral, demographic,\nand socioeconomic factors',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ] else ...[
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
