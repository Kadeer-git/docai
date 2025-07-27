// symptom_analyzer_screen.dart
import 'package:flutter/material.dart';
import 'gemini_api.dart';
import 'diagnosis_screen.dart';

class SymptomAnalyzerScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const SymptomAnalyzerScreen({super.key, required this.patient});

  @override
  State<SymptomAnalyzerScreen> createState() => _SymptomAnalyzerScreenState();
}

class _SymptomAnalyzerScreenState extends State<SymptomAnalyzerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController symptomController = TextEditingController();
  final TextEditingController doctorDiagnosisController =
      TextEditingController();

  List<String> symptoms = [];
  List<String> aiSuggestedSymptoms = [];
  List<Map<String, dynamic>> aiDiseases = [];

  bool isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    symptomController.dispose();
    doctorDiagnosisController.dispose();
    super.dispose();
  }

  void addSymptom(String symptom) async {
    if (symptom.trim().isEmpty) return;
    setState(() => symptoms.add(symptom.trim()));
    symptomController.clear();

    if (symptoms.length >= 3) {
      setState(() => isLoading = true);
      final related = await fetchRelatedSymptoms(symptoms);
      final diseases = await fetchSuggestedDiseases(symptoms);
      setState(() {
        aiSuggestedSymptoms = related;
        aiDiseases = diseases;
        isLoading = false;
      });
    }
  }

  void confirmDiagnostics() {
    final diagnosis = doctorDiagnosisController.text.trim();
    if (diagnosis.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisScreen(diseaseName: diagnosis),
      ),
    );
  }

  void resetAll() {
    setState(() {
      symptoms.clear();
      aiSuggestedSymptoms.clear();
      aiDiseases.clear();
      symptomController.clear();
      doctorDiagnosisController.clear();
      isLoading = false;
    });
  }

  Widget buildPillLoader() {
    return Center(
      child: SizedBox(
        width: 100,
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return ScaleTransition(
              scale: Tween(begin: 0.6, end: 1.2).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
                ),
              ),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Symptom Analyzer"),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  "${patient['name']}, ${patient['gender']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Age: ${patient['age']}"),
                leading: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Enter Symptoms:",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: symptomController,
              onSubmitted: addSymptom,
              decoration: InputDecoration(
                hintText: "e.g. Cough, Fever",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => symptomController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: symptoms
                  .map((s) => Chip(
                        label: Text(s),
                        backgroundColor: Colors.deepPurple.shade100,
                      ))
                  .toList(),
            ),
            if (isLoading) ...[
              const SizedBox(height: 20),
              buildPillLoader(),
            ],
            if (aiSuggestedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("AI Suggested Symptoms:",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: aiSuggestedSymptoms
                    .map((s) => ActionChip(
                          label: Text(s),
                          onPressed: () => addSymptom(s),
                          backgroundColor: Colors.indigo.shade50,
                        ))
                    .toList(),
              ),
            ],
            if (aiDiseases.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("AI Suggested Diseases:",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Column(
                children: aiDiseases
                    .map((d) => Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(d['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: d['confidence'],
                                  color: d['color'],
                                  backgroundColor: Colors.grey[300],
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            const Text("Doctor's Final Diagnosis:",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: doctorDiagnosisController,
              decoration: InputDecoration(
                hintText: "e.g. Pneumonia",
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: confirmDiagnostics,
                    icon: const Icon(Icons.check, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    label: const Text("Confirm Diagnosis",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: resetAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child:
                      const Text("Reset", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
