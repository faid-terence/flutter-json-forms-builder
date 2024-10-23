import 'package:json_form_flutter/models/field_options.dart';

class TemplateOptions {
  final String? type;
  final bool required;
  final String label;
  final String? placeholder;
  final List<FieldOptions>? options;
  final int? rows;
  final Map<String, dynamic>? summaryFormatting;
  final String summarySection;

  TemplateOptions({
    this.type,
    this.required = false,
    required this.label,
    this.options,
    this.placeholder,
    this.rows,
    required this.summarySection,
    this.summaryFormatting,
  });

  factory TemplateOptions.fromJson(Map<String, dynamic> json) {
    List<FieldOptions>? options;
    if (json['options'] != null) {
      options = (json['options'] as List)
          .map(
              (option) => FieldOptions.fromJson(option as Map<String, dynamic>))
          .toList();
    }

    return TemplateOptions(
      type: json['type'] as String?,
      required: json['required'] as bool? ?? false,
      label: json['label'],
      placeholder: json['placeholder'],
      options: options,
      rows: json['rows'],
      summarySection: json['summarySection'],
      summaryFormatting: json['summaryFormatting'] as Map<String, dynamic>?,
    );
  }
}
