import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/atoms/app_counter.dart';
import '../../../../core/storage/supabase_storage.dart';
import '../../../../core/widgets/atoms/app_filter_chip.dart';

class ProductInventoryCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(String size, int newQuantity) onStockChanged;
  final Function(double newPrice) onPriceChanged;
  final Function(String size) onAddSize;
  final Function(String size) onDeleteSize;
  final Function(File image) onImageUpdate;
  final VoidCallback onDelete;

  const ProductInventoryCard({
    required this.product,
    required this.onStockChanged,
    required this.onPriceChanged,
    required this.onAddSize,
    required this.onDeleteSize,
    required this.onImageUpdate,
    required this.onDelete,
    super.key,
  });

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      onImageUpdate(File(result.files.single.path!));
    }
  }

  void _showAddSizeDialog(BuildContext context) {
    final List<String> allSizes = ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'];
    final stocks = product['stocks'] as List<dynamic>? ?? [];
    final existingSizes = stocks.map((s) => s['size']).toList();
    final availableSizes = allSizes
        .where((s) => !existingSizes.contains(s))
        .toList();

    if (availableSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toutes les tailles sont déjà présentes')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une taille'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSizes
              .map(
                (size) => AppFilterChip(
                  label: size,
                  isSelected: false,
                  onSelected: (_) {
                    Navigator.pop(context);
                    onAddSize(size);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stocks = product['stocks'] as List<dynamic>? ?? [];
    final String name = product['name'] ?? 'Inconnu';
    final String id = product['id'] ?? '0';
    final String? imageUri = product['imageUri'];

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit avec bouton d'édition
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: imageUri != null
                          ? FutureBuilder<String>(
                              future: SupabaseStorageService()
                                  .getProfileImageUrl(imageUri),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  return Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    key: ValueKey(
                                      imageUri,
                                    ), // Important pour forcer le refresh
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image),
                                  );
                                }
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Icon(Icons.image_outlined),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Détails du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nouveau : Champ de prix
                    Row(
                      children: [
                        const Icon(Icons.sell_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final currentPriceStr = (product['price'] ?? 0)
                                  .toString()
                                  .replaceAll('.', ',');
                              final controller = TextEditingController(
                                text: currentPriceStr,
                              );
                              final newPrice = await showDialog<double>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Modifier le prix'),
                                  content: TextField(
                                    controller: controller,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      suffixText: '€',
                                      labelText: 'Prix de vente',
                                    ),
                                    autofocus: true,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        double.tryParse(
                                          controller.text.replaceAll(',', '.'),
                                        ),
                                      ),
                                      child: const Text('Valider'),
                                    ),
                                  ],
                                ),
                              );
                              if (newPrice != null) onPriceChanged(newPrice);
                            },
                            child: Row(
                              children: [
                                Text(
                                  '${(product['price'] ?? 0).toStringAsFixed(2).replaceAll('.', ',')} €',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Supprimer
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                iconSize: 22,
                tooltip: 'Supprimer le produit',
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Text(
                'Stocks disponibles :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddSizeDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Taille', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Liste des tailles et compteurs triés
          ...(() {
            final List<String> sizeOrder = [
              'XS',
              'S',
              'M',
              'L',
              'XL',
              '2XL',
              '3XL',
            ];
            final sortedStocks = List<dynamic>.from(stocks)
              ..sort((a, b) {
                final aIndex = sizeOrder.indexOf(a['size']);
                final bIndex = sizeOrder.indexOf(b['size']);
                return aIndex.compareTo(bIndex);
              });

            return sortedStocks.map((stock) {
              final String size = stock['size'];
              final int quantity = stock['quantity'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    AppCounter(
                      value: quantity,
                      onIncrement: () => onStockChanged(size, quantity + 1),
                      onDecrement: () => onStockChanged(size, quantity - 1),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => onDeleteSize(size),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              );
            }).toList();
          })(),
        ],
      ),
    );
  }
}
