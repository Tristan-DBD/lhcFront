import 'package:flutter/material.dart';
import '../../../user/data/models/user.dart';
import '../../data/models/course.dart';
import '../../data/services/course_service.dart';
import '../../../user/data/services/user_service.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/date_time_picker.dart';
import '../../../../core/widgets/generic_dropdown.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;
  final Function()? onCourseUpdated;

  const EditCourseScreen({
    required this.course,
    super.key,
    this.onCourseUpdated,
  });

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variables d'état
  bool _isLoading = false;
  DateTime? _courseDateTime;
  int? _selectedCoachId;
  List<User> _coaches = [];

  // Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _maxParticipantsController;

  // Focus nodes pour la navigation entre champs
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();
  final _maxParticipantsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadCoaches();
  }

  void _initializeFields() {
    _titleController = TextEditingController(text: widget.course.title);
    _descriptionController = TextEditingController(
      text: widget.course.description ?? '',
    );
    _durationController = TextEditingController(
      text: widget.course.durationMinutes.toString(),
    );
    _maxParticipantsController = TextEditingController(
      text: widget.course.maxParticipants.toString(),
    );
    _selectedCoachId = widget.course.coachId;
    _courseDateTime = widget.course.startAt;
  }

  @override
  void dispose() {
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

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) return;

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
        if (_courseDateTime != null)
          'startAt': _courseDateTime!.toIso8601String(),
        if (_selectedCoachId != null) 'coachId': _selectedCoachId,
      };

      final response = await CourseService.update(widget.course.id, courseData);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cours mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCourseUpdated?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la mise à jour: ${response.errorMessage ?? 'Erreur inconnue'}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du cours: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
          'Modifier un cours',
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
                FocusScope.of(context).unfocus();
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
              selectedItem: _coaches.isNotEmpty
                  ? _coaches.firstWhere(
                      (coach) => coach.id == _selectedCoachId,
                      orElse: () => _coaches.first,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            AppDateTimePicker(
              labelText: 'Date et heure du cours',
              hintText: 'Quand aura lieu le cours ?',
              prefixIcon: Icons.schedule,
              initialDateTime: _courseDateTime,
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
              text: 'Mettre à jour le cours',
              isFullWidth: true,
              height: 50,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _updateCourse,
            ),
          ],
        ),
      ),
    );
  }
}
