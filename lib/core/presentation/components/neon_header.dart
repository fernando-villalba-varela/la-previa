import 'package:flutter/material.dart';

class NeonHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color themeColor;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const NeonHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.themeColor,
    this.onBack,
    this.padding = const EdgeInsets.all(20.0),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding,
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack ?? () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: themeColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: themeColor,
                    shadows: [
                      Shadow(
                        color: themeColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 12, top: 0),
            child: Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
      ],
    );
  }
}
