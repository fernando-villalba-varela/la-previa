import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pack.dart';

class PackService extends ChangeNotifier {
  // Lista centralizada de packs disponibles
  final List<Pack> availablePacks = const [
    Pack(
      id: 'classic',
      nameKey: 'pack_classic',
      descriptionKey: 'pack_classic_desc',
      icon: Icons.local_fire_department,
      isPremium: false,
    ),
    Pack(
      id: 'bar',
      nameKey: 'pack_bar',
      descriptionKey: 'pack_bar_desc',
      icon: Icons.sports_bar,
      isPremium: true,
    ),
    Pack(
      id: 'home',
      nameKey: 'pack_home',
      descriptionKey: 'pack_home_desc',
      icon: Icons.home,
      isPremium: true,
    ),
    Pack(
      id: 'christmas',
      nameKey: 'pack_christmas',
      descriptionKey: 'pack_christmas_desc',
      icon: Icons.ac_unit,
      isPremium: true,
    ),
    Pack(
      id: 'valentine',
      nameKey: 'pack_valentine',
      descriptionKey: 'pack_valentine_desc',
      icon: Icons.favorite,
      isPremium: true,
    ),
  ];

  Set<String> _purchasedPackIds = {};
  bool _isPremium = false;
  
  bool get isPremium => _isPremium;

  // Por defecto, solo el clásico está activo en Quick Game, pero en el modo Liga se pueden seleccionar múltiples.
  Set<String> _activePackIds = {'classic'};

  Set<String> get activePackIds => _activePackIds;
  List<Pack> get activePacks => availablePacks.where((p) => _activePackIds.contains(p.id)).toList();

  // Método temporal para simular si el usuario tiene Premium y, por ende, todos los packs o si compró individuales
  bool isPackPurchased(String packId) {
    // Si es gratuito, siempre está "comprado"
    final pack = availablePacks.firstWhere((p) => p.id == packId, orElse: () => availablePacks.first);
    if (!pack.isPremium) return true;
    if (_isPremium) return true;
    return _purchasedPackIds.contains(packId);
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPurchases = prefs.getStringList('purchased_packs') ?? [];
    _purchasedPackIds = savedPurchases.toSet();
    
    _isPremium = prefs.getBool('is_premium_user') ?? false;
    
    final savedActive = prefs.getStringList('active_packs') ?? [];
    _activePackIds = savedActive.toSet();
    _activePackIds.add('classic'); // el clásico siempre está activo

    notifyListeners();
  }

  Future<void> simulatePurchase(String packId) async {
    final prefs = await SharedPreferences.getInstance();

    if (packId == 'premium_global') {
      _isPremium = true;
      await prefs.setBool('is_premium_user', true);
      // Optionally auto-activate everything or just notify
      notifyListeners();
      return;
    }

    _purchasedPackIds.add(packId);
    await prefs.setStringList('purchased_packs', _purchasedPackIds.toList());
    
    // Al comprar, lo activamos automáticamente
    togglePackActive(packId, true);
    notifyListeners();
  }

  Future<void> togglePackActive(String packId, bool isActive, {bool bypassPurchase = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (isActive) {
      if (bypassPurchase || isPackPurchased(packId)) {
        _activePackIds.add(packId);
      }
    } else {
      if (packId == 'classic') return; // el clásico no se puede desactivar
      _activePackIds.remove(packId);
      if (_activePackIds.isEmpty) {
        _activePackIds.add('classic');
      }
    }
    
    await prefs.setStringList('active_packs', _activePackIds.toList());
    notifyListeners();
  }

  /// Canjea un código de desarrollador. Devuelve true si el código es válido.
  Future<bool> redeemDevCode(String code) async {
    const validCodes = ['DUENDEBORRACHO_3'];
    if (!validCodes.contains(code.toUpperCase().trim())) return false;
    await simulatePurchase('premium_global');
    return true;
  }
}
