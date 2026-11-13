import 'package:flutter/material.dart';

import 'planning_page.dart';

class MingguPage extends StatelessWidget {
  final bool m1;
  final ValueChanged<String> onGo;
  const MingguPage({super.key, required this.m1, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return PlanningPage(onGo: onGo);
  }
}
