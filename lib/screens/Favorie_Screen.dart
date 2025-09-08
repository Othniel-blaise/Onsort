import 'package:flutter/material.dart';

class FavorieScreen extends StatelessWidget {
  const FavorieScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header avec le titre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Favoris',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Liste des favoris
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildFavoriItem(
                      title: 'Eclipse Club',
                      subtitle: 'Club',
                      onTap: () {
                        // Navigation vers Eclipse Club
                        print('Naviguer vers Eclipse Club');
                      },
                    ),
                    _buildFavoriItem(
                      title: 'Prestige Bar',
                      subtitle: 'Bar dansant',
                      onTap: () {
                        // Navigation vers Prestige Bar
                        print('Naviguer vers Prestige Bar');
                      },
                    ),
                    _buildFavoriItem(
                      title: 'Seduction Lounge',
                      subtitle: '1,2 km',
                      onTap: () {
                        // Navigation vers Seduction Lounge
                        print('Naviguer vers Seduction Lounge');
                      },
                    ),
                    _buildFavoriItem(
                      title: 'Maquis Snack',
                      subtitle: 'Maquis',
                      onTap: () {
                        // Navigation vers Maquis Snack
                        print('Naviguer vers Maquis Snack');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      
      
    );
  }

  Widget _buildFavoriItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icône cœur rouge
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 14,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Texte (titre et sous-titre)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.red : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.red : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}



