import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_error_state.dart';
import 'app_loading.dart';

class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final Widget Function(T data)? empty;
  final String? loadingMessage;
  final VoidCallback? onRetry;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.empty,
    this.loadingMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        if (isEmpty != null && empty != null && isEmpty!(d)) {
          return empty!(d);
        }
        return data(d);
      },
      loading: () => AppLoadingIndicator(message: loadingMessage),
      error: (e, _) => AppErrorState(error: e, onRetry: onRetry),
    );
  }
}
