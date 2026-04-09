import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/language_service.dart';
import '../../../../../core/services/pack_service.dart';
import '../../../presentation/viewmodels/league_detail_viewmodel.dart';
import '../../../../../core/models/player.dart';
import 'package:drinkaholic/features/league/presentation/screens/league_game_screen.dart';
import 'package:drinkaholic/features/league/presentation/screens/game_results_screen.dart';

class PlayTab extends StatefulWidget {
  const PlayTab({super.key});

  @override
  State<PlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends State<PlayTab> {
  final Set<int> _selected = {};
  bool _isProcessingGameEnd = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkCustomQuestions() async {
    // Legacy check removed
  }

  ImageProvider? _avatar(String? path) {
    if (path == null) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    final f = File(path);
    if (f.existsSync()) return FileImage(f);
    return null;
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _saveGameResults(Map<int, int> playerDrinks, int mvpId, int ratitaId) {
    final vm = context.read<LeagueDetailViewModel>();
    vm.recordMatch(playerDrinks, Provider.of<LanguageService>(context, listen: false), mvpId: mvpId, ratitaId: ratitaId);
    setState(() {
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeagueDetailViewModel>();
    final players = vm.league.players;

    // Si no hay jugadores, mostrar mensaje
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports_outlined, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              Provider.of<LanguageService>(context).translate('no_players_title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              Provider.of<LanguageService>(context).translate('add_players_hint'),
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: players.length + 1, // +1 para la sección de packs
            itemBuilder: (_, i) {
              if (i == 0) {
                return Consumer<PackService>(
                  builder: (context, packService, _) {
                    final languageService = Provider.of<LanguageService>(context);
                    final availablePacks = packService.availablePacks;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 4),
                          child: Text(
                            languageService.translate('packs_tab').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFF00C9FF),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: availablePacks.length,
                            itemBuilder: (context, index) {
                              final pack = availablePacks[index];
                              final isActive = packService.activePackIds.contains(pack.id);
                              final isPurchased = packService.isPackPurchased(pack.id);

                              return GestureDetector(
                                onTap: () {
                                  if (isPurchased) {
                                    packService.togglePackActive(pack.id, !isActive);
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 12, bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF00C9FF).withOpacity(0.15)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isActive
                                          ? const Color(0xFF00C9FF)
                                          : Colors.white10,
                                      width: isActive ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isPurchased ? pack.icon : Icons.lock,
                                        color: isActive ? const Color(0xFF00C9FF) : Colors.white38,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        languageService.translate(pack.nameKey),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                          color: isActive ? Colors.white : Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 4),
                          child: Text(
                            languageService.translate('players_tab').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFF00C9FF),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                );
              }
              
              final p = players[i - 1]; // Ajuste por la sección de packs
              final selected = _selected.contains(p.playerId);
              final img = _avatar(p.avatarPath);
              return Card(
                elevation: 0,
                color: selected
                    ? const Color(0xFF00C9FF).withOpacity(0.18)
                    : Theme.of(context).cardColor.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: selected ? const Color(0xFF00C9FF) : const Color(0x40808080),
                    width: selected ? 1.5 : 1.2,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _toggle(p.playerId),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: img,
                          child: img == null
                              ? Text(
                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected ? const Color(0xFF00C9FF) : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
              icon: const Icon(Icons.local_drink),
              label: Text(
                (_selected.length >= 2 && players.length >= 2)
                    ? (Provider.of<LanguageService>(context).translate('start_playing_button'))
                    : (players.length < 2
                        ? Provider.of<LanguageService>(context).translate('need_at_least_2')
                        : Provider.of<LanguageService>(context).translate('select_at_least_2')),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                disabledBackgroundColor: const Color(0x5987CEEB),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: (_selected.length >= 2 && players.length >= 2)
                  ? () {
                      // Capturar el TabController ANTES de navegar
                      final tabController = DefaultTabController.of(context);

                      // Convertir los jugadores seleccionados de LeaguePlayerStats a Player
                      final selectedPlayers = players.where((p) => _selected.contains(p.playerId)).map((leaguePlayer) {
                        // Convertir avatarPath a File o mantener como asset
                        File? imagen;
                        String? avatar;

                        if (leaguePlayer.avatarPath != null) {
                          if (leaguePlayer.avatarPath!.startsWith('assets/')) {
                            avatar = leaguePlayer.avatarPath;
                          } else {
                            final file = File(leaguePlayer.avatarPath!);
                            if (file.existsSync()) {
                              imagen = file;
                            }
                          }
                        }

                        return Player(
                          id: leaguePlayer.playerId,
                          nombre: leaguePlayer.name,
                          imagen: imagen,
                          avatar: avatar,
                        );
                      }).toList();

                      // Navegar a LeagueGameScreen con los jugadores convertidos
                      // Generar número aleatorio entre 30 y 50 rondas
                      final random = Random();
                      final maxRounds = 30 + random.nextInt(21); // 30 a 50

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeagueGameScreen(
                            players: selectedPlayers,
                            maxRounds: maxRounds,
                            leagueId: vm.league.id,
                            onGameEnd: (playerDrinks) {
                              // Prevenir múltiples ejecuciones
                              if (_isProcessingGameEnd) return;
                              _isProcessingGameEnd = true;

                              // Navegar a GameResultsScreen — recordMatch se llama en onConfirm
                              // con los IDs ya resueltos (incluyendo desempates manuales)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameResultsScreen(
                                    players: selectedPlayers,
                                    playerDrinks: playerDrinks,
                                    maxRounds: maxRounds,
                                    onConfirm: (mvpId, ratitaId) {
                                      // Guardar resultado con los IDs resueltos por la pantalla
                                      _saveGameResults(playerDrinks, mvpId, ratitaId);
                                      // Cerrar GameResultsScreen
                                      Navigator.pop(context);
                                      // Cerrar también LeagueGameScreen para volver a PlayTab
                                      Navigator.pop(context);
                                      // Cambiar a la pestaña del scoreboard usando el controlador capturado
                                      if (mounted) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          tabController.animateTo(0);
                                        });
                                      }
                                      // Resetear el flag
                                      _isProcessingGameEnd = false;
                                    },
                                  ),
                                ),
                              ).then((_) {
                                // Resetear el flag si se cierra la pantalla de otra manera
                                _isProcessingGameEnd = false;
                              });
                            },
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
          ],
        ),
        ),
      ],
    );
  }
}





