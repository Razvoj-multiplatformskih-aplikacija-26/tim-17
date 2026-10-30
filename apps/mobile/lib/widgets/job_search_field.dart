import 'package:flutter/material.dart';

class JobSearchField extends StatelessWidget {
  const JobSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Pozicija, poslodavac ili šifra',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
        prefixIcon: Icon(Icons.search_rounded, color: muted),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Obriši pretragu',
                icon: Icon(Icons.cancel_rounded, size: 20, color: muted),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}
