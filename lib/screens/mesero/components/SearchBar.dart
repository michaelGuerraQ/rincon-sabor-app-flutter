import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/widgets/input_search.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const SearchBar({
    super.key,
    this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomSearchBar(
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
      ),
    );
  }
}