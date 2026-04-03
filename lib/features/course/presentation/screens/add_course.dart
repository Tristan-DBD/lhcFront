import 'package:flutter/material.dart';
import '../../data/services/course_service.dart';
import '../../../user/data/services/user_service.dart';
import '../../../user/data/models/user.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/date_time_picker.dart';
import '../../../../core/widgets/generic_dropdown.dart';

class AddCourseScreen extends StatefulWidget {
  final Function()? onCourseCreated;

  const AddCourseScreen({super.key, this.onCourseCreated});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  DateTime? _courseDateTime;
  String? _selectedCoachId;
  List<User> _coaches = [];

  // Focus nodes pour la navigation entre les champs
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();
  final _maxParticipantsFocusNode = FocusNode();

  @override
  void dispose() {
    // Libérer les ressources
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _durationFocusNode.dispose();
    _maxParticipantsFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    try {
      final response = await UserService.getAllCoach();
      if (response.success && response.data != null) {
        setState(() {
          _coaches = response.data!;
        });
      }
    } catch (e) {
      // Erreur chargement coaches
    }
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier si une date a été sélectionnée
    if (_courseDateTime == null) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Veuillez sélectionner une date et heure pour le cours',
          isError: true,
        );
      }
      return;
    }

    // Vérifier si un coach a été sélectionné
    if (_selectedCoachId == null) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Veuillez sélectionner un coach',
          isError: true,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'durationMinutes': int.tryParse(_durationController.text.trim()) ?? 0,
        'maxParticipants':
            int.tryParse(_maxParticipantsController.text.trim()) ?? 0,
        'startAt': _courseDateTime!.toIso8601String(),
        'coachId': _selectedCoachId,
      };
      final response = await CourseService.create(courseData);
      if (response.success) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Cours créé avec succès',
          );
        }
        // Notifier la page parente que le cours a été créé
        widget.onCourseCreated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Erreur lors de la création du cours: $e',
          isError: true,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ajouter un cours',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: _form(),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _titleController,
              labelText: 'Titre',
              hintText: 'Entrez le titre',
              prefixIcon: Icons.title,
              keyboardType: TextInputType.text,
              focusNode: _titleFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Entrez la description',
              prefixIcon: Icons.description,
              keyboardType: TextInputType.text,
              focusNode: _descriptionFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_durationFocusNode);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _durationController,
              labelText: 'Durée',
              hintText: 'Entrez la durée en minutes',
              prefixIcon: Icons.schedule,
              keyboardType: TextInputType.number,
              focusNode: _durationFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_maxParticipantsFocusNode);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _maxParticipantsController,
              labelText: 'Max participants',
              hintText: 'Entrez le nombre maximum de participants',
              prefixIcon: Icons.groups,
              keyboardType: TextInputType.number,
              focusNode: _maxParticipantsFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                FocusScope.of(context).unfocus(); // Fermer le clavier
              },
            ),
            const SizedBox(height: 16),
            GenericDropdown<User>(
              items: _coaches,
              displayString: (coach) => coach.fullName,
              onSelected: (coach) {
                setState(() {
                  _selectedCoachId = coach.id;
                });
              },
              hintText: 'Sélectionner un coach',
              labelText: 'Coach',
              prefixIcon: Icons.person,
              leadingWidget: (coach) => CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  coach.name.isNotEmpty ? coach.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppDateTimePicker(
              labelText: 'Date et heure du cours',
              hintText: 'Quand aura lieu le cours ?',
              prefixIcon: Icons.schedule,
              onDateTimeChanged: (dateTime) {
                _courseDateTime = dateTime;
              },
              validator: (dateTime) {
                if (dateTime == null) {
                  return 'Veuillez sélectionner une date et heure';
                }
                if (dateTime.isBefore(DateTime.now())) {
                  return 'La date ne peut pas être dans le passé';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'Ajouter le cours',
              isFullWidth: true,
              height: 50,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _createCourse,
            ),
          ],
        ),
      ),
    );
  }
}
