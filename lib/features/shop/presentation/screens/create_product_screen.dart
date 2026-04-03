import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/atoms/app_filter_chip.dart';
import '../../data/services/shop_service.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _shopService = ShopService();

  final List<String> _allSizes = ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'];
  final List<String> _selectedSizes = [];

  bool _isLoading = false;
  bool _showImageInput = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSizes.isEmpty) {
      MessageService.showError(
        context,
        'Veuillez sélectionner au moins une taille',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _shopService.createProduct(
        {
          'name': _nameController.text,
          'price': double.parse(_priceController.text.replaceAll(',', '.')),
          'sizes': _selectedSizes,
        },
        _showImageInput ? _selectedImage : null,
      );

      if (response['success'] == true) {
        if (mounted) {
          MessageService.showSuccess(context, 'Produit créé avec succès');
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          MessageService.showError(
            context,
            response['data']?[0]?['message'] ?? 'Erreur lors de la création',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Sortie de route: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Produit'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations Générales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _nameController,
                      labelText: 'Nom du produit',
                      hintText: 'ex: T-shirt Oversize Noir',
                      prefixIcon: Icons.shopping_bag_outlined,
                      validator: (value) =>
                          Validators.required(value, 'le nom'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _priceController,
                      labelText: 'Prix de vente',
                      hintText: 'ex: 29.99',
                      prefixIcon: Icons.euro_symbol,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final res = Validators.required(value, 'le prix');
                        if (res != null) return res;
                        final normalizedValue = value!.replaceAll(',', '.');
                        if (double.tryParse(normalizedValue) == null) return 'Prix invalide';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tailles disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cochez les tailles que vous souhaitez vendre pour ce produit.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allSizes.map((size) {
                        final isSelected = _selectedSizes.contains(size);
                        return AppFilterChip(
                          label: size,
                          isSelected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSizes.add(size);
                              } else {
                                _selectedSizes.remove(size);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Bloc Image (Design "Creative Dropzone")
              AnimatedCrossFade(
                firstChild: AppButton(
                  text: 'Ajouter une image',
                  onPressed: () => setState(() => _showImageInput = true),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo, size: 20),
                      SizedBox(width: 8),
                      Text('Ajouter une image'),
                    ],
                  ),
                ),

                secondChild: Column(
                  children: [
                    const Text(
                      'Aperçu du produit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Container(
                          width: 180,
                          height: 180,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 48,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Glisser ou cliquer',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showImageInput = false;
                          _selectedImage = null;
                        });
                      },
                      child: Text(
                        'Annuler l\'ajout d\'image',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                crossFadeState: _showImageInput
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Créer le produit',
                isFullWidth: true,
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
