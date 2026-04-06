import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/language_service.dart';
import '../../../../../core/services/pack_service.dart';

class PacksTab extends StatelessWidget {
  const PacksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PackService, LanguageService>(
      builder: (context, packService, languageService, child) {
        final packs = packService.availablePacks;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: packs.length,
          itemBuilder: (context, index) {
            final pack = packs[index];
            final isActive = packService.activePackIds.contains(pack.id);

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
                  pack.icon,
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
                trailing: Checkbox(
                  value: isActive,
                  activeColor: const Color(0xFF00FFFF),
                  checkColor: Colors.black,
                  onChanged: (value) {
                    if (value != null) {
                      packService.togglePackActive(pack.id, value, bypassPurchase: true);
                    }
                  },
                ),
                onTap: () {
                  packService.togglePackActive(pack.id, !isActive, bypassPurchase: true);
                },
              ),
            );
          },
        );
      },
    );
  }
}
