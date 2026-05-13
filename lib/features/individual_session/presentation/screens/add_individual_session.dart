import 'package:flutter/material.dart';
import '../../data/services/individual_session_service.dart';
import '../../../user/data/services/user_service.dart';
import '../../../user/data/models/user.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/date_time_picker.dart';
import '../../../../core/widgets/generic_dropdown.dart';

class AddIndividualSessionScreen extends StatefulWidget {
  final Function()? onSessionCreated;

  const AddIndividualSessionScreen({super.key, this.onSessionCreated});

  @override
  State<AddIndividualSessionScreen> createState() =>
      _AddIndividualSessionScreenState();
}

class _AddIndividualSessionScreenState
    extends State<AddIndividualSessionScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime? _sessionDateTime;
  String? _selectedCoachId;
  List<User> _coaches = [];

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();

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

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sessionDateTime == null) {
      if (mounted) {
        MessageService.showError(
          context,
          'Veuillez sélectionner une date et heure pour la séance',
        );
      }
      return;
    }

    if (_selectedCoachId == null) {
      if (mounted) {
        MessageService.showError(context, 'Veuillez sélectionner un coach');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final sessionData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'durationMinutes': int.tryParse(_durationController.text.trim()) ?? 0,
        'startAt': _sessionDateTime!.toIso8601String(),
        'coachId': _selectedCoachId,
      };
      final response = await IndividualSessionService.create(sessionData);
      if (response.success) {
        if (mounted) {
          MessageService.showSuccess(context, 'Séance créée avec succès');
        }
        widget.onSessionCreated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(
          context,
          'Erreur lors de la création: $e',
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
          'Ajouter une séance',
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
            ),
            const SizedBox(height: 16),
            AppDateTimePicker(
              labelText: 'Date et heure',
              hintText: 'Quand aura lieu la séance ?',
              prefixIcon: Icons.schedule,
              onDateTimeChanged: (dateTime) {
                _sessionDateTime = dateTime;
              },
              validator: (dateTime) {
                if (dateTime == null) {
                  return 'Veuillez sélectionner une date et heure';
                }
                if (dateTime.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)),
                )) {
                  return 'La date ne peut pas être dans le passé';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'Ajouter la séance',
              isFullWidth: true,
              height: 50,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _createSession,
            ),
          ],
        ),
      ),
    );
  }
}
