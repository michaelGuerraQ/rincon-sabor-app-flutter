import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class Navbar extends StatelessWidget {
  final Widget contenido;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Navbar({
    super.key,
    required this.contenido,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: contenido,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.black.withValues(alpha:0.3)
                : Colors.grey.withValues(alpha:0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark 
            ? const Color(0xFF2D3748) 
            : Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark 
            ? Colors.white.withValues(alpha:0.6)
            : Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: selectedIndex == 0
                    ? BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  selectedIndex == 0 
                    ? Icons.dashboard_rounded 
                    : Icons.dashboard_outlined,
                  size: 24,
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: selectedIndex == 1
                    ? BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  selectedIndex == 1 
                    ? Icons.history_rounded 
                    : Icons.history_outlined,
                  size: 24,
                ),
              ),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: selectedIndex == 2
                    ? BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  selectedIndex == 2 
                    ? Icons.people_rounded 
                    : Icons.people_outline_rounded,
                  size: 24,
                ),
              ),
              label: 'Usuarios',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: selectedIndex == 3
                    ? BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  selectedIndex == 3 
                    ? Icons.restaurant_menu_rounded 
                    : Icons.restaurant_menu_outlined,
                  size: 24,
                ),
              ),
              label: 'Productos',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: selectedIndex == 4
                    ? BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  selectedIndex == 4 
                    ? Icons.person_rounded 
                    : Icons.person_outline_rounded,
                  size: 24,
                ),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
