import 'package:flutter/material.dart';

class PaddingContainer extends StatelessWidget {
  final Widget child;

  const PaddingContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: child,
    );
  }
}
