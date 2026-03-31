import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A large, colorful card for the home screen menu items.
/// Matches the reference design with a background decorative icon,
/// a foreground icon, title, and subtitle.
class HomeGameCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData backgroundIcon;
  final List<Color> gradientColors;
  final Color textColor;
  final VoidCallback onTap;
  final double height;
  final bool compact;

  const HomeGameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundIcon,
    required this.gradientColors,
    required this.onTap,
    this.textColor = Colors.white,
    this.height = 160,
    this.compact = false,
  });

  @override
  State<HomeGameCard> createState() => _HomeGameCardState();
}

class _HomeGameCardState extends State<HomeGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative icon
              Positioned(
                right: 16,
                top: widget.compact ? 12 : 20,
                bottom: widget.compact ? 12 : 20,
                child: Icon(
                  widget.backgroundIcon,
                  size: widget.compact ? 70 : 110,
                  color: widget.textColor.withOpacity(0.12),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(widget.compact ? 16 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: widget.compact
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.end,
                  children: [
                    if (!widget.compact) ...[
                      // Small icon in a circle
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: widget.textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.textColor,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                    ],
                    if (widget.compact)
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: widget.textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.textColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.poppins(
                                    color: widget.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle,
                                  style: GoogleFonts.inter(
                                    color: widget.textColor.withOpacity(0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: widget.textColor.withOpacity(0.6),
                            size: 28,
                          ),
                        ],
                      )
                    else ...[
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          color: widget.textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.inter(
                          color: widget.textColor.withOpacity(0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
