import 'package:flutter/material.dart';
import '../../../../../core/models/player.dart';

class LetterCounterOverlay extends StatefulWidget {
  final List<Player> selectedPlayers;
  final String letter;
  final int drinksPerLetter;
  final Function(Map<int, int>) onConfirm;

  const LetterCounterOverlay({
    super.key,
    required this.selectedPlayers,
    required this.letter,
    required this.drinksPerLetter,
    required this.onConfirm,
  });

  @override
  State<LetterCounterOverlay> createState() => _LetterCounterOverlayState();
}

class _LetterCounterOverlayState extends State<LetterCounterOverlay> {
  final Map<int, int> _letterCounts = {};

  @override
  void initState() {
    super.initState();
    for (final player in widget.selectedPlayers) {
      _letterCounts[player.id] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600 || screenSize.height < 400;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.abc, color: Colors.white.withOpacity(0.6), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Conteo de letra "${widget.letter}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '· ${widget.drinksPerLetter} trago${widget.drinksPerLetter > 1 ? 's' : ''}/letra',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de jugadores
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  60,
                ),
                child: Column(
                  children: widget.selectedPlayers.map((player) {
                    final selectedCount = _letterCounts[player.id] ?? 0;
                    final totalDrinks = selectedCount * widget.drinksPerLetter;

                    return Container(
                      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A4E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: totalDrinks > 0
                              ? const Color(0xFF00C9FF).withOpacity(0.6)
                              : Colors.white.withOpacity(0.08),
                          width: totalDrinks > 0 ? 2 : 1,
                        ),
                        boxShadow: totalDrinks > 0
                            ? [BoxShadow(color: const Color(0xFF00C9FF).withOpacity(0.15), blurRadius: 8)]
                            : null,
                      ),
                      child: Column(
                        children: [
                          // Avatar + Nombre + Contador de tragos
                          Row(
                            children: [
                              _buildPlayerAvatar(player, isSmallScreen),
                              SizedBox(width: isSmallScreen ? 10 : 12),
                              Expanded(
                                child: Text(
                                  player.nombre,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Badge de tragos
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 10 : 12,
                                  vertical: isSmallScreen ? 5 : 7,
                                ),
                                decoration: BoxDecoration(
                                  gradient: totalDrinks > 0
                                      ? const LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)])
                                      : null,
                                  color: totalDrinks > 0 ? null : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_drink, color: Colors.white, size: isSmallScreen ? 14 : 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$totalDrinks',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 10 : 12),

                          // Selectores 0–5
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              final isSelected = selectedCount == index;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _letterCounts[player.id] = index),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 7 : 9),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)])
                                          : null,
                                      color: isSelected ? null : Colors.white.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.white.withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '$index',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          ]),
          // Botón pill flotante minimalista
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final playersWithDrinks = <int, int>{};
                  _letterCounts.forEach((playerId, count) {
                    final total = count * widget.drinksPerLetter;
                    if (total > 0) playersWithDrinks[playerId] = total;
                  });
                  widget.onConfirm(playersWithDrinks);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0055), Color(0xFFFF5588)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF0055).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'CONFIRMAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPlayerAvatar(Player player, bool isSmallScreen) {
    final size = isSmallScreen ? 34.0 : 40.0;

    if (player.imagen != null) {
      return ClipOval(
        child: Image.file(player.imagen!, width: size, height: size, fit: BoxFit.cover),
      );
    } else if (player.avatar != null && player.avatar!.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(player.avatar!, width: size, height: size, fit: BoxFit.cover),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
        ),
        child: Center(
          child: Text(
            player.nombre[0].toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: size * 0.45, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
