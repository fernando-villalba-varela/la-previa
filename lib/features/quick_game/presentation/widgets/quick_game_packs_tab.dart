import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

            return Card(
              color: isActive ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isActive ? const Color(0xFF00FFFF) : Colors.white24,
                  width: isActive ? 2 : 1,
                ),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: Icon(
                  isPurchased ? pack.icon : Icons.lock,
                  color: isActive ? const Color(0xFF00FFFF) : Colors.white54,
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
                trailing: isPurchased ? Checkbox(
                  value: isActive,
                  activeColor: const Color(0xFF00FFFF),
                  checkColor: Colors.black,
                  onChanged: (value) {
                    if (value != null) {
                      packService.togglePackActive(pack.id, value);
                    }
                  },
                ) : const Icon(Icons.shopping_cart, color: Colors.white54),
                onTap: () {
                  if (isPurchased) {
                    packService.togglePackActive(pack.id, !isActive);
                  } else {
                    _showPurchaseDialog(context, packService, pack.id, languageService.translate(pack.nameKey));
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showPurchaseDialog(BuildContext context, PackService packService, String packId, String packName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(
          'Desbloquear $packName',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Simulación de compra de Google Play.\n\n¿Deseas añadir este pack a tu cuenta?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0055)),
            onPressed: () {
              packService.simulatePurchase(packId);
              Navigator.pop(ctx);
            },
            child: const Text('Comprar (Simulado)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
