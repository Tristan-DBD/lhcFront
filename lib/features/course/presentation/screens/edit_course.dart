import 'package:flutter/material.dart';
import 'package:lhc_front/services/course.dart';
import 'package:lhc_front/services/user.dart';
import 'package:lhc_front/widgets/app_button.dart';
import 'package:lhc_front/widgets/app_text_field.dart';
import 'package:lhc_front/widgets/date_time_picker.dart';
import 'package:lhc_front/widgets/generic_dropdown.dart';
import '../../../../constant/app_colors.dart';

class EditCourseScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  final Function()? onCourseUpdated;

  const EditCourseScreen({
    super.key,
    required this.course,
    this.onCourseUpdated,
  });

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _maxParticipantsController;
  DateTime? _courseDateTime;
  int? _selectedCoachId;
  List<Map<String, dynamic>> _coaches = [];

  // Focus nodes pour la navigation entre les champs
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
    _titleController = TextEditingController(
      text: widget.course['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.course['description'] ?? '',
    );
    _durationController = TextEditingController(
      text: widget.course['durationMinutes']?.toString() ?? '',
    );
    _maxParticipantsController = TextEditingController(
      text: widget.course['maxParticipants']?.toString() ?? '',
    );
    _selectedCoachId = widget.course['coachId'];

    if (widget.course['startAt'] != null) {
      try {
        _courseDateTime = DateTime.parse(widget.course['startAt']);
      } catch (e) {
        print('Erreur parsing date: $e');
      }
    }
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
      if (response['success'] == true) {
        setState(() {
          _coaches = List<Map<String, dynamic>>.from(
            response['data'][0]['message'],
          );
        });
      }
    } catch (e) {
      print('Erreur chargement coaches: $e');
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

      final response = await CourseService.update(
        widget.course['id'],
        courseData,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
              'Erreur lors de la mise à jour: ${response['message'] ?? 'Erreur inconnue'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du cours: $e'),
          backgroundColor: Colors.red,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier un cours',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        centerTitle: true,
      ),
      body: _form(),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
            GenericDropdown<Map<String, dynamic>>(
              items: _coaches,
              displayString: (coach) => '${coach['name']} ${coach['surname']}',
              onSelected: (coach) {
                setState(() {
                  _selectedCoachId = coach['id'];
                });
              },
              hintText: 'Sélectionner un coach',
              labelText: 'Coach',
              prefixIcon: Icons.person,
              leadingWidget: (coach) => CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (coach['name'] ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              selectedItem: _coaches.isNotEmpty
                  ? _coaches.firstWhere(
                      (coach) => coach['id'] == _selectedCoachId,
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
                if (dateTime == null)
                  return 'Veuillez sélectionner une date et heure';
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
