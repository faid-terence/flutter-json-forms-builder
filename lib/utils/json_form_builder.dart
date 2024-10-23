import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_form_flutter/components/my_custom_button.dart';
import 'package:json_form_flutter/models/form_field_config.dart';

class JsonFormBuilder extends StatefulWidget {
  final List<dynamic> jsonFormFields;
  final Function(Map<String, dynamic>) onSubmit;
  const JsonFormBuilder({
    super.key,
    required this.jsonFormFields,
    required this.onSubmit,
  });

  @override
  State<JsonFormBuilder> createState() => _JsonFormBuilderState();
}

class _JsonFormBuilderState extends State<JsonFormBuilder> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill out the form',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...widget.jsonFormFields.map((field) {
              final config =
                  FormFieldConfig.fromJson(field as Map<String, dynamic>);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildFormField(config),
              );
            }).toList(),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: MyCustomButton(
                  text: "Submit",
                  onPressed: _submitForm,
                  buttonStyle: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.blueAccent,
                    elevation: 5.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(FormFieldConfig config) {
    switch (config.type) {
      case 'custom-input':
        return _buildTextFormField(config);
      case 'custom-select':
        return _buildDropdownField(config);
      case 'custom-date':
        return _buildDateField(config);
      case 'custom-radio':
        return _buildRadioField(config);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextFormField(FormFieldConfig config) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: config.templateOptions.label,
        hintText: config.templateOptions.placeholder,
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      ),
      maxLines: config.templateOptions.rows ?? 1,
      keyboardType: _getKeyboardType(config.templateOptions.type),
      validator: (value) {
        if (config.templateOptions.required &&
            (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _formData[config.key] = value;
        });
      },
      onSaved: (value) {
        _formData[config.key] = value;
      },
    );
  }

  Widget _buildDropdownField(FormFieldConfig config) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: config.templateOptions.label,
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      ),
      value: _formData[config.key] as String?,
      items: config.templateOptions.options?.map((option) {
        return DropdownMenuItem(
          value: option.value,
          child: Text(option.name),
        );
      }).toList(),
      validator: (value) {
        if (config.templateOptions.required && value == null) {
          return 'This field is required';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _formData[config.key] = value;
        });
      },
    );
  }

  Widget _buildDateField(FormFieldConfig config) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: config.templateOptions.label,
        hintText: config.templateOptions.placeholder,
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon:
            const Icon(Icons.calendar_today_outlined, color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      ),
      readOnly: true,
      controller: TextEditingController(text: _formData[config.key] as String?),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          final format = config.templateOptions.summaryFormatting?['dateFormat']
                  as String? ??
              'MM/dd/yyyy';
          setState(() {
            _formData[config.key] = DateFormat(format).format(date);
          });
        }
      },
      validator: (value) {
        if (config.templateOptions.required &&
            (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildRadioField(FormFieldConfig config) {
    return FormField<String>(
      initialValue: _formData[config.key] as String?,
      validator: (value) {
        if (config.templateOptions.required && value == null) {
          return 'This field is required';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.templateOptions.label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...config.templateOptions.options!.map((option) {
              return RadioListTile<String>(
                title: Text(option.name),
                value: option.value,
                groupValue: _formData[config.key] as String?,
                onChanged: (value) {
                  setState(() {
                    _formData[config.key] = value;
                    state.didChange(value);
                  });
                },
              );
            }),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  TextInputType _getKeyboardType(String? type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
      case 'email':
        return TextInputType.emailAddress;
      case 'tel':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(_formData);
      // clear form data after submission
    }
  }
}
