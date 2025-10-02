import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/screens/admin/components/navbar.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/dashboardScreen/dashboard.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/historialUsuario.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/history_pedidos.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/perfiladmin.dart';

class AdminMain extends StatefulWidget {
  final Usuario usuario;
  const AdminMain({super.key, required this.usuario});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  int _selectedIndex = 0;

  List<Widget> get _pantallas => [
    const DashboardScreen(),
    const HistoryPedidosScreen(),
    const HistorialUsuario(),
    const MenuScreen(),
    Perfiladmin(usuario: widget.usuario),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // QUITÉ EL MaterialApp - Eso era lo que causaba el problema
    // Ahora solo devuelvo el navbar y usa el tema del main.dart
    return Navbar(
      contenido: _pantallas[_selectedIndex],
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }
}
