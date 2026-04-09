import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/pack.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/pack_service.dart';

class QuickGamePacksTab extends StatelessWidget {
  const QuickGamePacksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PackService, LanguageService>(
      builder: (context, packService, languageService, child) {
        final packs = packService.availablePacks;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: packs.length,
          itemBuilder: (context, index) {
            final pack = packs[index];
            final isActive = packService.activePackIds.contains(pack.id);
            final isPurchased = packService.isPackPurchased(pack.id);

            if (!isPurchased) {
              return _LockedPackCard(
                pack: pack,
                languageService: languageService,
                packService: packService,
              );
            }

            return Card(
              color: isActive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isActive
                      ? const Color(0xFF00FFFF)
                      : Colors.white24,
                  width: isActive ? 2 : 1,
                ),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: Icon(
                  pack.icon,
                  color: isActive
                      ? const Color(0xFF00FFFF)
                      : Colors.white54,
                  size: 32,
                ),
                title: Text(
                  languageService.translate(pack.nameKey),
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    languageService.translate(pack.descriptionKey),
                    style: TextStyle(
                      color: isActive ? Colors.white70 : Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ),
                trailing: Checkbox(
                  value: isActive,
                  activeColor: const Color(0xFF00FFFF),
                  checkColor: Colors.black,
                  onChanged: (value) {
                    if (value != null) {
                      packService.togglePackActive(pack.id, value);
                    }
                  },
                ),
                onTap: () => packService.togglePackActive(pack.id, !isActive),
              ),
            );
          },
        );
      },
    );
  }
}

class _LockedPackCard extends StatefulWidget {
  final Pack pack;
  final LanguageService languageService;
  final PackService packService;

  const _LockedPackCard({
    required this.pack,
    required this.languageService,
    required this.packService,
  });

  @override
  State<_LockedPackCard> createState() => _LockedPackCardState();
}

class _LockedPackCardState extends State<_LockedPackCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    _showPurchaseDialog();
  }

  void _showPurchaseDialog() {
    final lang = widget.languageService;
    final packName = lang.translate(widget.pack.nameKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(
          lang.translate('unlock_pack_title').replaceAll('{name}', packName),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          lang.translate('unlock_pack_content'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.translate('cancel'), style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0055)),
            onPressed: () {
              widget.packService.simulatePurchase(widget.pack.id);
              Navigator.pop(ctx);
            },
            child: Text(lang.translate('buy_button'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Stack(
            children: [
              // Contenido desaturado
              Opacity(
                opacity: 0.35,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  leading:
                      Icon(widget.pack.icon, color: Colors.white, size: 32),
                  title: Text(
                    widget.languageService.translate(widget.pack.nameKey),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.languageService
                          .translate(widget.pack.descriptionKey),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                    ),
                  ),
                  trailing: const SizedBox(width: 32),
                ),
              ),
              // Candado a la derecha
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(Icons.lock,
                            color: Colors.white60, size: 20),
                      ),
                    ),
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
