import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/router/app_router.dart';
import 'package:flutter_pos/core/theme/app_theme.dart';
import 'package:flutter_pos/data/seed/dev_data_seeder.dart';
import 'package:flutter_pos/data/repositories/drift_product_repository.dart';
import 'package:flutter_pos/presentation/providers/database_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedData();
  }

  Future<void> _seedData() async {
    try {
      final db = ref.read(databaseProvider);
      final seeder = DevDataSeeder(
        DriftProductRepository(db),
      );
      await seeder.seed();
    } catch (e, st) {
      debugPrint('Seeding failed: $e\n$st');
    }
    if (mounted) {
      setState(() => _seeded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
