import 'package:flutter/material.dart';

import '../auth_gate.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthGate()),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: scheme.surface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Today's Language",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '화면을 터치해서 시작하기',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
