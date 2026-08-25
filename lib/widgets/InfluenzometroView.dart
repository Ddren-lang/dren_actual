// lib/widgets/influenzometro_container.dart
import 'package:flutter/material.dart';
import 'package:dren/plantillas/influenzometro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/influencer_service.dart';


class InfluenzometroContainer extends StatefulWidget {
  const InfluenzometroContainer({super.key});

  @override
  State<InfluenzometroContainer> createState() => _InfluenzometroContainerState();
}

class _InfluenzometroContainerState extends State<InfluenzometroContainer> {
  double progress = 0.0;
  String latestAchievement = '';
  Map<int, String> achievements = {};

  bool isLoading = true;
  String error = '';
@override
void initState() {
  super.initState();
_loadStats();
}

// Future<void> _storeTestUserId() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('userId', '1'); // Pon aquí un ID válido para probar
// }


Future<void> _loadStats() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      if (!mounted) return; // <--- agregamos esto
      setState(() {
        error = 'User ID no encontrado';
        isLoading = false;
      });
      return;
    }

    print('Llamando API con userId: $userId');

    final data = await InfluencerService.fetchStats(userId);
    print('Respuesta API: $data');

    final achMap = Map<String, dynamic>.from(data['achievements']);
    final parsedAchievements = achMap.map((k, v) => MapEntry(int.parse(k), v.toString()));

    if (!mounted) return; // <--- agregamos esto
    setState(() {
      progress = (data['progress_percent'] as num).toDouble();
      latestAchievement = data['latest_achievement'];
      achievements = parsedAchievements;
      isLoading = false;
    });
  } catch (e) {
    print('Error al cargar métricas: $e');
    if (!mounted) return; // <--- agregamos esto
    setState(() {
      error = 'Error al cargar las métricas: $e';
      isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(child: Text(error, style: const TextStyle(color: Color.fromARGB(255, 8, 8, 8))));
    }

    return InfluenzometroView(
      progressPercent: progress,
      latestAchievement: latestAchievement,
      achievements: achievements,
    );
  }
}
