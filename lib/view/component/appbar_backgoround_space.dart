import 'package:flutter/material.dart';

class AppbarBackgroundSpace extends StatelessWidget {
  const AppbarBackgroundSpace({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
    );
  }
}