import 'package:flutter/material.dart';

/// Wrapper que aplica SafeArea + padding padrão em todas as telas.
class SafePage extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const SafePage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(padding: padding, child: child),
    );
  }
}
