import 'package:json_form_flutter/models/template_options.dart';

class FormFieldConfig {
  final String key;
  final String type;
  final TemplateOptions templateOptions;

  FormFieldConfig({
    required this.key,
    required this.type,
    required this.templateOptions,
  });

  factory FormFieldConfig.fromJson(Map<String, dynamic> json) {
    return FormFieldConfig(
      key: json['key'],
      type: json['type'],
      templateOptions: TemplateOptions.fromJson(json['templateOptions']),
    );
  }
}
