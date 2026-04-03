import 'package:flutter/material.dart';
import '../../../../core/widgets/feature_card.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'create_product_screen.dart';
import 'inventory_screen.dart';
import 'coach_orders_summary_screen.dart';
import 'coach_all_orders_screen.dart';

class ShopManagementScreen extends StatelessWidget {
  const ShopManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Gestion Boutique',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveHelper.getHorizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Outils de vente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(
                    context,
                  ),
                  crossAxisSpacing: ResponsiveHelper.getGridSpacing(context),
                  mainAxisSpacing: ResponsiveHelper.getGridSpacing(context),
                  children: [
                    FeatureCard(
                      icon: Icons.add_business,
                      title: 'Nouveau Produit',
                      description: 'Ajouter à la boutique',
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateProductScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Inventaire & Stock',
                      description: 'Gérer les quantités',
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryScreen(),
                        ),
                      ),
                    ),
                    FeatureCard(
                      icon: Icons.receipt_long,
                      title: 'Historique des commandes',
                      description: 'Suivi & changement d\'état',
                      color: Colors.orange,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CoachAllOrdersScreen(),
                        ),
                      ),
                    ),
                    FeatureCard(
                      icon: Icons.assessment_outlined,
                      title: 'Résumé de production',
                      description: 'Aggrégation par taille',
                      color: Colors.blue,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CoachOrdersSummaryScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
