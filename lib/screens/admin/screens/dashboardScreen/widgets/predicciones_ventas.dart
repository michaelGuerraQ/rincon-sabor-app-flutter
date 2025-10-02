import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/view_model/prediccion_ventas.dart';
import 'package:rincon_sabor_flutter/core/services/clima_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

/// Widget profesional para mostrar predicciones de ventas
class PrediccionVentasWidget extends StatelessWidget {
  const PrediccionVentasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _obtenerDatosCompletos(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Card(
            color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Analizando datos...',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        if (snap.hasError) {
          return Card(
            color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snap.error}',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snap.data!;
        final predicciones = data['predicciones'] as Map<String, double>;
        final temperatura = data['temperatura'] as double;
        final diaManana = data['dia'] as String;

        // Filtrar predicciones > 0 y ordenar por cantidad (mayor a menor)
        final prediccionesFiltradas = predicciones.entries
            .where((e) => e.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (prediccionesFiltradas.isEmpty) {
          return Card(
            color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.insights, size: 48, color: AppColors.warning),
                  const SizedBox(height: 16),
                  Text(
                    'No hay suficientes datos para predicciones',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del clima
                _buildHeader(context, temperatura, diaManana, isDark),
                
                const SizedBox(height: 20),
                
                // Plato más vendido (destacado)
                _buildPlatoDestacado(context, prediccionesFiltradas.first, isDark),
                
                const SizedBox(height: 16),
                
                // Resto de predicciones
                _buildListaPredicciones(context, prediccionesFiltradas.skip(1).toList(), isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _obtenerDatosCompletos() async {
    final predicciones = await predecirVentasManana();
    final temperatura = await obtenerTemperaturaManana();
    final manana = DateTime.now().add(const Duration(days: 1));
    
    const diasSemana = [
      'Domingo', 'Lunes', 'Martes', 'Miércoles', 
      'Jueves', 'Viernes', 'Sábado'
    ];
    
    return {
      'predicciones': predicciones,
      'temperatura': temperatura,
      'dia': diasSemana[manana.weekday % 7],
    };
  }

  Widget _buildHeader(BuildContext context, double temperatura, String dia, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.secondary.withOpacity(0.2) : AppColors.secondaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.secondary.withOpacity(0.3) : AppColors.secondary,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.insights,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predicción para $dia',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.thermostat, 
                      size: 16, 
                      color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${temperatura.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatoDestacado(BuildContext context, MapEntry<String, double> plato, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.success.withOpacity(0.2) : AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.success.withOpacity(0.3) : AppColors.primary,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plato más demandado',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  plato.key,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${plato.value.round()} unidades',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaPredicciones(BuildContext context, List<MapEntry<String, double>> predicciones, bool isDark) {
    if (predicciones.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otras predicciones',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...predicciones.map((prediccion) => _buildItemPrediccion(prediccion, isDark)),
      ],
    );
  }

  Widget _buildItemPrediccion(MapEntry<String, double> prediccion, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF4A5568) : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3748) : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prediccion.key,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${prediccion.value.round()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}