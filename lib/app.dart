import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/fuel_entry_provider.dart';
import 'screens/app_shell.dart';
import 'theme.dart';

class FuelCalApp extends StatelessWidget {
  const FuelCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => FuelEntryProvider()),
      ],
      child: const _AppInit(),
    );
  }
}

class _AppInit extends StatefulWidget {
  const _AppInit();

  @override
  State<_AppInit> createState() => _AppInitState();
}

class _AppInitState extends State<_AppInit> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final vp = context.read<VehicleProvider>();
    final fp = context.read<FuelEntryProvider>();
    vp.onVehicleSelected = (vehicle) => fp.loadForVehicle(vehicle);
    vp.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuelIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}
