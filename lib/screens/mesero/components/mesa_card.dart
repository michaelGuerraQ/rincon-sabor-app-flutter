import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';

class MesaCard extends StatelessWidget {
  final Mesa mesa;
  final VoidCallback onTap;

  const MesaCard({
    Key? key,
    required this.mesa,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = mesa.estado == EstadoMesa.mantenimiento;
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748), // Superficie dark
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(mesa.colorValue).withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Color(mesa.colorValue).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculamos tamaños basados en las dimensiones disponibles
            final availableHeight = constraints.maxHeight;
            
            // Tamaños adaptativos
            final iconSize = (availableHeight * 0.25).clamp(20.0, 40.0);
            final titleFontSize = (availableHeight * 0.12).clamp(12.0, 18.0);
            final stateFontSize = (availableHeight * 0.08).clamp(8.0, 12.0);
            final padding = (availableHeight * 0.08).clamp(8.0, 16.0);
            
            return Container(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Icono principal - Flexible para adaptarse
                  Flexible(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Container(
                        width: iconSize + 16,
                        height: iconSize + 16,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Color(mesa.colorValue).withOpacity(0.3),
                              Color(mesa.colorValue).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(mesa.colorValue).withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _getIconForEstado(mesa.estado),
                          color: Color(mesa.colorValue),
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                  
                  // Espaciador flexible
                  const Flexible(
                    flex: 1,
                    child: SizedBox(height: 4),
                  ),
                  
                  // Número de mesa - Flexible para adaptarse
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Mesa ${mesa.numero}',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  
                  // Espaciador flexible
                  const Flexible(
                    flex: 1,
                    child: SizedBox(height: 2),
                  ),
                  
                  // Estado - Flexible para adaptarse
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: padding * 0.6,
                          vertical: padding * 0.3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(mesa.colorValue).withOpacity(0.2),
                              Color(mesa.colorValue).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(mesa.colorValue).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Color(mesa.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: padding * 0.3),
                            Text(
                              mesa.estadoLabel,
                              style: TextStyle(
                                fontSize: stateFontSize,
                                fontWeight: FontWeight.w600,
                                color: Color(mesa.colorValue),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Indicador de disponibilidad - Solo si hay espacio
                  if (!isDisabled && availableHeight > 100)
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(top: padding * 0.5),
                        width: double.infinity,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(mesa.colorValue).withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForEstado(EstadoMesa estado) {
    switch (estado) {
      case EstadoMesa.disponible:
        return Icons.table_restaurant;
      case EstadoMesa.ocupada:
        return Icons.people;
      case EstadoMesa.esperando:
        return Icons.access_time;
      case EstadoMesa.mantenimiento:
        return Icons.build;
    }
  }
}
