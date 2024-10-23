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
          errorMessage = "Failed to load form fields, Please try again";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occured: $e';
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
        title: const Text('JSON Form Flutter'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      JsonFormBuilder(
                        jsonFormFields: formFields!,
                        onSubmit: (formData) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Form Submission'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: formData.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Text(
                                        '${entry.key}: ${entry.value}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
