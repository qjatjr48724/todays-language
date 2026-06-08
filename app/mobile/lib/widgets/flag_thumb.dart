import 'package:flutter/material.dart';


/// 국가 플래그 썸네일 (public_metadata flagUrl).
class FlagThumb extends StatelessWidget {
    const FlagThumb({super.key, required this.url});

    final String? url;


    @override
    Widget build(BuildContext context) {
        final scheme = Theme.of(context).colorScheme;
        return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
                (url ?? ''),
                width: 28,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 28,
                    height: 20,
                    color: scheme.surfaceContainerHighest,
                ),
            ),
        );
    }
}
