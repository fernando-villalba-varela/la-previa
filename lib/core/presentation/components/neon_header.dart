import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color themeColor;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;

  const NeonHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.themeColor,
    this.onBack,
    this.padding = const EdgeInsets.all(20.0),
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
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: themeColor.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: themeColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                    color: themeColor,
                    shadows: [
                      Shadow(
                        color: themeColor.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 12, top: 0),
            child: Text(
              subtitle!,
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
      ],
    );
  }
}
