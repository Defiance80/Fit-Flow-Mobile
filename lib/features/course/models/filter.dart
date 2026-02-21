import 'package:fitflow/common/widgets/custom_expandable_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Filter {
  final String titleKey;
  final String apiKey;
  final List<FilterValue> values;
  final bool isMultiSelection;
  List<FilterValue> selectedValues;
  late ValueNotifier<List<FilterValue>> selectedValuesNotifier;

  Filter({
    required this.titleKey,
    required this.apiKey,
    required this.values,
    required this.selectedValues,
    this.isMultiSelection = true,
  });

  void initNotifier() {
    selectedValuesNotifier = ValueNotifier(selectedValues);
  }

  void disposeNotifier() {
    selectedValuesNotifier.dispose();
  }

  Widget filterItem(FilterValue value, int index) {
    if (isMultiSelection) {
      return CheckboxListTile(
        value: selectedValuesNotifier.value.contains(value),
        title: Text(value.toString()),
        onChanged: (isSelected) {
          if (isSelected == true) {
            selectedValuesNotifier.value = List.from(
              selectedValuesNotifier.value,
            )..add(value);
            selectedValues = List.from(selectedValuesNotifier.value);
          } else {
            selectedValuesNotifier.value = List.from(
              selectedValuesNotifier.value,
            )..remove(value);
            selectedValues = List.from(selectedValuesNotifier.value);
          }
        },
      );
    } else {
      return RadioGroup<FilterValue>(
        groupValue: selectedValuesNotifier.value.isNotEmpty
            ? selectedValuesNotifier.value.first
            : null,
        onChanged: (value) {
          if (value != null) {
            if (value == selectedValuesNotifier.value.firstOrNull) {
              selectedValuesNotifier.value = [];
            } else {
              selectedValuesNotifier.value = [value];
            }
            selectedValues = List.from(selectedValuesNotifier.value);
          }
        },
        child: RadioListTile(
          value: value,
          controlAffinity: .trailing,
          title: Text(value.toString()),
        ),
      );
    }
  }

  Widget build() {
    return ValueListenableBuilder(
      valueListenable: selectedValuesNotifier,
      builder: (context, value, child) {
        return CustomExpandableTile(
          title: toString(),
          isExpanded: true,
          onToggle: () {},
          content: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: values.length,
            shrinkWrap: true,
            padding: .zero,
            itemBuilder: (context, index) {
              return filterItem(values[index], index);
            },
          ),
        );
      },
    );
  }

  @override
  String toString() {
    return titleKey.tr;
  }
}

class FilterValue {
  final String titleKey;
  final String apiValue;

  FilterValue({required this.titleKey, required this.apiValue});

  @override
  String toString() {
    return titleKey.tr;
  }
}

extension FilterListExtensions on List<Filter> {
  Map<String, dynamic> get apiExtraParams {
    return Map<String, dynamic>.fromEntries(
      map((e) {
        return MapEntry<String, dynamic>(
          e.apiKey,
          e.selectedValues.map((e) => e.apiValue).join(','),
        );
      }),
    );
  }

  bool get hasAppliedFilters {
    return !every((element) => element.selectedValues.isEmpty);
  }
}
