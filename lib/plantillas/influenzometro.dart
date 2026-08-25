import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfluenzometroView extends StatelessWidget {
  final double progressPercent;
  final String latestAchievement;
  final Map<int, String> achievements;

  const InfluenzometroView({
    super.key,
    required this.progressPercent,
    required this.latestAchievement,
    required this.achievements,
  });
  Future<Map<String, dynamic>> fetchInfluencerStats(String token) async {
  final response = await http.get(
    Uri.parse('https://www.iidlive.com/api/puntos'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Error al cargar las métricas');
  }
}

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.9;

    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              'Influenzómetro',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'Progreso: ${(progressPercent * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 9),
            Stack(
              children: [
                Container(
                  width: width,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  width: width * progressPercent,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 211, 230),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                ...achievements.keys.map((points) {
                  final double pos = (points / 500).clamp(0, 1) * width;
                  final bool reached = progressPercent >= (points / 500);
                  return Positioned(
                    left: pos - 7,
                    top: -5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: reached ? Colors.greenAccent : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black45, width: 1.5),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              latestAchievement,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
