import 'package:flutter/material.dart';
import 'gemini_api.dart';

class DiagnosisScreen extends StatefulWidget {
  final String diseaseName;
  DiagnosisScreen({required this.diseaseName});

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  Map<String, List<String>> diagnosisDetails = {
    'symptoms': [],
    'drugs': [],
    'tests': [],
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    final data = await fetchDiagnosisDetails(widget.diseaseName);
    setState(() {
      diagnosisDetails = data;
      isLoading = false;
    });
  }

  Widget buildListSection(String title, List<String> items, IconData icon) {
    if (items.isEmpty) return SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(fontSize: 16)),
                      Expanded(
                          child:
                              Text(item, style: const TextStyle(fontSize: 15)))
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Diagnosis: ${widget.diseaseName}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: (diagnosisDetails['symptoms']!.isEmpty &&
                      diagnosisDetails['drugs']!.isEmpty &&
                      diagnosisDetails['tests']!.isEmpty)
                  ? const Center(
                      child: Text('No diagnosis details found.',
                          style: TextStyle(fontSize: 16)),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildListSection(
                              'AI Suggested Symptoms',
                              diagnosisDetails['symptoms']!,
                              Icons.medical_services_outlined),
                          buildListSection(
                              'Prescribed Drugs',
                              diagnosisDetails['drugs']!,
                              Icons.medication_outlined),
                          buildListSection(
                              'Recommended Tests',
                              diagnosisDetails['tests']!,
                              Icons.science_outlined),
                        ],
                      ),
                    ),
            ),
    );
  }
}
