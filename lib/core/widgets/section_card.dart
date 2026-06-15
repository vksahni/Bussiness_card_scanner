import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    final trailingWidget = trailing;
    final trailingWidgets =
        trailingWidget == null ? const <Widget>[] : <Widget>[trailingWidget];
    final headerTexts = <Widget>[
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      if (subtitleText != null) ...[
        const SizedBox(height: 6),
        Text(subtitleText, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: headerTexts,
                  ),
                ),
                ...trailingWidgets,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
