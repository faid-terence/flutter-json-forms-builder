class FieldOptions {
  final String name;
  final String value;

  FieldOptions({required this.name, required this.value});

  factory FieldOptions.fromJson(Map<String, dynamic> json) {
    return FieldOptions(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }
}
