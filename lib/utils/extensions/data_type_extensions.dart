import 'dart:async';
import 'dart:ui';

import 'package:fitflow/common/models/language_model.dart';
import 'package:fitflow/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

extension StringExtension on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidUrl => Uri.tryParse(this)?.hasAbsolutePath ?? false;

  // String get capitalize =>
  //     isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get currency {
    return '${Get.context?.read<SettingsCubit>().currencySymbol} $this';
  }

  String translateWithTemplate(Map<String, String> params) {
    return tr.replaceAllMapped(
      RegExp(r'\{{(\w+)\}}'),
      (Match match) => params[match.group(1)] ?? '',
    );
  }

  bool containsAny(List<String> list) {
    if (list.any((element) => contains(element))) {
      return true;
    } else {
      return false;
    }
  }

  /// Strips HTML tags from the string and decodes HTML entities
  String get stripHtmlTags {
    if (isEmpty) return this;

    // Remove HTML tags
    String result = replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode common HTML entities
    result = result
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '…')
        .replaceAll('&bull;', '•');

    // Trim extra whitespace
    return result.trim();
  }
}

extension NumExtension on num {
  String get toStringWithCommas {
    final String number = toString();
    if (number.length >= 4) {
      return number.replaceRange(3, 4, ',');
    }
    return number;
  }

  double minMaxNormalize(double min, double max) {
    if (min == max) return 0.0; // Avoid division by zero
    return (this - min) / (max - min);
  }
}

extension MapEx<K, V> on Map<K, V> {
  Map<K, V> removeEmptyKeys() {
    removeWhere((key, value) {
      return value == null || value == '';
    });

    return this;
  }

  Iterable<U> mapIndexed<U>(U Function(V e, int i) f) {
    var i = 0;
    return values.map<U>((it) {
      final t = i;
      i++;
      return f(it, t);
    });
  }
}

extension StreamEx<T> on Stream<T> {
  // Adds an `mapIndexed` method to Streams, which allows mapping with index
  Stream<U> mapIndexed<U>(U Function(T e, int i) f) {
    var i = 0;
    return transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(f(data, i));
          i++;
        },
      ),
    );
  }
}

extension IndexedAny<E> on List<E> {
  /// Checks if any element in the list satisfies the given [test] function.
  /// Provides the element and its index to the [test] function.
  /// Returns true if any element satisfies the condition.
  bool indexedAny(bool Function(E element, int index) test) {
    for (var i = 0; i < length; i++) {
      if (test(this[i], i)) {
        return true;
      }
    }
    return false;
  }

  List<E> get unique => toSet().toList();
  List<List<E>> chunked(int size) {
    final List<List<E>> chunks = [];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  E? get(int index) {
    try {
      return this[index];
    } catch (e) {
      return null;
    }
  }
}

extension LanguageListExtension on List<Language> {
  List<Locale> get supported =>
      map((language) => Locale(language.local)).toList();
  List<String> get supportedLocalString =>
      map((language) => language.local).toList();
}

extension DynamicExtension on Object {
  int? forceInt([int? defaultValue]) {
    if (this is String) {
      return int.parse(this as String);
    } else if (this is int) {
      return this as int;
    } else if (this is double) {
      return (this as double).toInt();
    } else if (this is num) {
      return (this as num).toInt();
    } else {
      return defaultValue;
    }
  }
}

extension JsonConversionExtensions on Map {
  T require<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw Exception(
      "Key '$key' requires type '$T' but got '${value.runtimeType}' with value: $value",
    );
  }

  T? optional<T>(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is T) return value;
    throw Exception(
      "Key '$key' requires type '$T' but got '${value.runtimeType}' with value: $value",
    );
  }
}
