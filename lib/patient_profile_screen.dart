import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'symptom_analyzer_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController recordController = TextEditingController();

  String? selectedGender;
  int selectedAge = 1;
  bool showAgePicker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Patient Profile"),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Patient Name",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter Name",
                prefixIcon: const Icon(Icons.person_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Gender", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: ["Male", "Female", "Other"]
                  .map((gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: (val) => setState(() => selectedGender = val),
              decoration: InputDecoration(
                hintText: "Select Gender",
                prefixIcon: const Icon(Icons.wc_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Age", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => showAgePicker = !showAgePicker),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$selectedAge years",
                        style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.deepPurple),
                  ],
                ),
              ),
            ),
            if (showAgePicker)
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 40,
                  magnification: 1.2,
                  useMagnifier: true,
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedAge - 1),
                  onSelectedItemChanged: (val) {
                    setState(() {
                      selectedAge = val + 1;
                    });
                  },
                  children: List.generate(
                    99,
                    (index) => Center(
                      child: Text(
                        "${index + 1} years",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text("Past Medical Record",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: recordController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter past medical record if any",
                prefixIcon: const Icon(Icons.notes_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (nameController.text.isEmpty || selectedGender == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SymptomAnalyzerScreen(
                        patient: {
                          'name': nameController.text,
                          'gender': selectedGender!,
                          'age': selectedAge.toString(),
                          'record': recordController.text,
                        },
                      ),
                    ),
                  );
                },
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text("Save and Proceed",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
