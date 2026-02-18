import 'package:flutter/material.dart';

class ConnectionIndicator extends StatelessWidget {
  final bool isConnected;
  final FontWeight fontWeight;

  const ConnectionIndicator({
    super.key,
    required this.isConnected,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.circle,
          size: 14,
          color: isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          isConnected ? 'Connected to Master Node' : 'Not Connected',
          style: TextStyle(fontWeight: fontWeight),
        ),
      ],
    );
  }
}