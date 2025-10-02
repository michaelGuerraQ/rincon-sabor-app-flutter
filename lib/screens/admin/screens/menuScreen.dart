import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/view_model/insumos_view_mode.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/categoriasListaScreen.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/insumosListScreen.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/productosListScreen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
          foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
          title: Text(
            'Almacén de Productos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor:
                isDark
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: [
              Tab(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fastfood, size: 20),
                ),
                text: 'Productos',
              ),
              Tab(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.kitchen, size: 20),
                ),
                text: 'Insumos',
              ),
              Tab(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.category, size: 20),
                ),
                text: 'Categorías',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProductosListScreen(),
            ChangeNotifierProvider(
              create: (_) => InsumosViewModel()..cargarInsumos(),
              child: const Insumoslistscreen(),
            ),
            CategoriasListScreen(),
          ],
        ),
      ),
    );
  }
}
