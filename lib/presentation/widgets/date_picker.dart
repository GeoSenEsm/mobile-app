import 'package:flutter/material.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';

class DatePicker extends StatefulWidget {
  DateTime? value;
  final void Function(DateTime?)? onValueChanged;
  final String? label;

  DatePicker({super.key, this.value, this.onValueChanged, this.label});

  @override
  State<StatefulWidget> createState() {
    return _DatePickerState();
  }
}

class _DatePickerState extends State<DatePicker> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null && picked != widget.value) {
      setState(() {
        widget.value = picked;
      });

      if (widget.onValueChanged != null) {
        widget.onValueChanged!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () {
        _selectDate(context);
      },
      controller: TextEditingController(
          text:
              widget.value == null ? null : dateOnlyShortFormat(widget.value!)),
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.calendar_month),
      ),
    );
  }
}
