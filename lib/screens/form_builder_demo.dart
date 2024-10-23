import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_form_flutter/utils/json_form_builder.dart';

class FormBuilderDemo extends StatefulWidget {
  const FormBuilderDemo({super.key});

  @override
  State<FormBuilderDemo> createState() => _FormBuilderDemoState();
}

class _FormBuilderDemoState extends State<FormBuilderDemo> {
  List<Map<String, dynamic>>? formFields;
  bool isLoading = true;
  String? errorMessage;

  Future<void> _fetchFormFields() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/formFields'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          formFields =
              data.map((field) => field as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load form fields. Please try again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFormFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _fetchFormFields();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
                )
              : formFields == null || formFields!.isEmpty
                  ? const Center(
                      child: Text(
                        'No form fields available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          JsonFormBuilder(
                            jsonFormFields: formFields!,
                            onSubmit: (formData) {
                              _showFormSubmissionDialog(formData);
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }

  void _showFormSubmissionDialog(Map<String, dynamic> formData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Submitted Successfully!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: formData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        '${entry.value}',
                        style: const TextStyle(fontSize: 16),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _fetchFormFields();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Form submission complete!'),
                ),
              );
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
