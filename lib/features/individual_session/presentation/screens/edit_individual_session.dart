import 'package:flutter/material.dart';
import '../../../user/data/models/user.dart';
import '../../data/models/individual_session.dart';
import '../../data/services/individual_session_service.dart';
import '../../../user/data/services/user_service.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/date_time_picker.dart';
import '../../../../core/widgets/generic_dropdown.dart';

class EditIndividualSessionScreen extends StatefulWidget {
  final IndividualSession session;
  final Function()? onSessionUpdated;

  const EditIndividualSessionScreen({
    required this.session,
    super.key,
    this.onSessionUpdated,
  });

  @override
  State<EditIndividualSessionScreen> createState() =>
      _EditIndividualSessionScreenState();
}

class _EditIndividualSessionScreenState
    extends State<EditIndividualSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  DateTime? _sessionDateTime;
  String? _selectedCoachId;
  List<User> _coaches = [];

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadCoaches();
  }

  void _initializeFields() {
    _titleController = TextEditingController(text: widget.session.title);
    _descriptionController = TextEditingController(
      text: widget.session.description ?? '',
    );
    _durationController = TextEditingController(
      text: widget.session.durationMinutes.toString(),
    );
    _selectedCoachId = widget.session.coachId;
    _sessionDateTime = widget.session.startAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _durationFocusNode.dispose();
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

  Future<void> _updateSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'durationMinutes': int.tryParse(_durationController.text.trim()) ?? 0,
        if (_sessionDateTime != null)
          'startAt': _sessionDateTime!.toIso8601String(),
        if (_selectedCoachId != null) 'coachId': _selectedCoachId,
      };

      final response =
          await IndividualSessionService.update(widget.session.id, sessionData);

      if (response.success) {
        if (mounted) {
          MessageService.showSuccess(context, 'Séance mise à jour avec succès');
        }
        widget.onSessionUpdated?.call();
        Navigator.pop(context);
      } else {
        if (mounted) {
          MessageService.showError(
            context,
            'Erreur: ${response.errorMessage ?? 'Erreur inconnue'}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(
          context,
          'Erreur lors de la mise à jour: $e',
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
          'Modifier la séance',
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
              labelText: 'Durée (minutes)',
              hintText: 'Entrez la durée en minutes',
              prefixIcon: Icons.schedule,
              keyboardType: TextInputType.number,
              focusNode: _durationFocusNode,
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
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
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
              labelText: 'Date et heure',
              hintText: 'Quand aura lieu la séance ?',
              prefixIcon: Icons.schedule,
              initialDateTime: _sessionDateTime,
              onDateTimeChanged: (dateTime) {
                _sessionDateTime = dateTime;
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
              text: 'Mettre à jour',
              isFullWidth: true,
              height: 50,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _updateSession,
            ),
          ],
        ),
      ),
    );
  }
}
