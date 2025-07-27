// gemini_api.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/material.dart';

final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: 'AIzaSyCA013rQqXwCy7oi-DB63sGOqniRzZz-Mk',
);

Future<List<String>> fetchRelatedSymptoms(List<String> symptoms) async {
  final prompt = """
Based on the following symptoms, suggest 5 related symptoms:
${symptoms.join(', ')}
Return them as a comma-separated list.
""";

  try {
    final content = Content.text(prompt);
    final response = await model.generateContent([content]);
    final output = response.text ?? '';
    return output
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  } catch (e) {
    print('AI Error (related symptoms): $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchSuggestedDiseases(
    List<String> symptoms) async {
  final prompt = """
Based on the following symptoms, suggest 3 possible diseases with a confidence score (0 to 1):
${symptoms.join(', ')}
Format:
Disease - confidence
""";

  try {
    final content = Content.text(prompt);
    final response = await model.generateContent([content]);
    final lines = response.text?.split('\n') ?? [];

    return lines
        .map((line) {
          final parts = line.split('-');
          if (parts.length != 2) return null;
          final name = parts[0].trim();
          final confidence = double.tryParse(parts[1].trim()) ?? 0.0;
          final color = confidence < 0.3
              ? const Color(0xFFF44336)
              : (confidence < 0.6
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF4CAF50));
          return {'name': name, 'confidence': confidence, 'color': color};
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  } catch (e) {
    print('AI Error (disease prediction): $e');
    return [];
  }
}

Future<Map<String, List<String>>> fetchDiagnosisDetails(
    String diseaseName) async {
  final prompt = """
You are a medical AI assistant. For the disease: "$diseaseName", provide:
- 3 to 5 common symptoms
- 3 to 5 commonly prescribed drugs
- 2 or more recommended lab or radiology tests

Respond in *exactly this format*:
Symptoms: symptom1, symptom2, symptom3
Drugs: drug1, drug2, drug3
Tests: test1, test2
""";

  try {
    final content = Content.text(prompt);
    final response = await model.generateContent([content]);

    print('Gemini response:\n${response.text}');

    final lines = response.text?.split('\n') ?? [];

    List<String> symptoms = [];
    List<String> drugs = [];
    List<String> tests = [];

    for (final line in lines) {
      if (line.toLowerCase().startsWith('symptoms:')) {
        symptoms = line
            .replaceFirst(RegExp(r'symptoms:', caseSensitive: false), '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (line.toLowerCase().startsWith('drugs:')) {
        drugs = line
            .replaceFirst(RegExp(r'drugs:', caseSensitive: false), '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (line.toLowerCase().startsWith('tests:')) {
        tests = line
            .replaceFirst(RegExp(r'tests:', caseSensitive: false), '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }

    return {
      'symptoms': symptoms,
      'drugs': drugs,
      'tests': tests,
    };
  } catch (e) {
    print('AI Error (diagnosis details): $e');
    return {
      'symptoms': [],
      'drugs': [],
      'tests': [],
    };
  }
}
