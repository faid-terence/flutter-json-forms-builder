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
    return Form(
        key: _formKey,
        child: Column(
          children: [
            ...widget.jsonFormFields.map((field) {
              final config =
                  FormFieldConfig.fromJson(field as Map<String, dynamic>);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildFormField(config),
              );
            }),
            const SizedBox(
              height: 20,
            ),
            MyCustomButton(
              text: "Submit",
              onPressed: _submitForm,
            )
          ],
        ));
  }

  Widget _buildFormField(FormFieldConfig configs) {
    switch (configs.type) {
      case 'custom-input':
        return _buildTextFormField(configs);

      case 'custom-select':
        return _buildDropdownField(configs);

      case 'custom-date':
        return _buildDateField(configs);

      case 'custom-radio':
        return _buildRadioField(configs);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextFormField(FormFieldConfig config) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: config.templateOptions.label,
        hintText: config.templateOptions.placeholder,
        border: const OutlineInputBorder(),
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
        border: const OutlineInputBorder(),
      ),
      // hint: Text(config.templateOptions!.placeholder),
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
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
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
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
    }
  }
}
