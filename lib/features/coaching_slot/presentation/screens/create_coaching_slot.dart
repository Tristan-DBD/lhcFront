import 'package:flutter/material.dart';
import 'package:lhc_front/core/widgets/date_picker.dart';
import 'package:lhc_front/core/widgets/time_picker.dart';
import '../../data/services/coaching_slot_service.dart';
import '../../../user/data/services/user_service.dart';
import '../../../user/data/models/user.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/generic_dropdown.dart';

class CreateCoachingSlotScreen extends StatefulWidget {
  final Function()? onSlotCreated;

  const CreateCoachingSlotScreen({super.key, this.onSlotCreated});

  @override
  State<CreateCoachingSlotScreen> createState() => _CreateCoachingSlotScreenState();
}

class _CreateCoachingSlotScreenState extends State<CreateCoachingSlotScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  DateTime? _slotDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedCoachId;
  List<User> _coaches = [];

  // Focus nodes pour la navigation entre les champs
  final _startTimeFocusNode = FocusNode();
  final _endTimeFocusNode = FocusNode();

  @override
  void dispose() {
    // Libérer les ressources
    _startTimeFocusNode.dispose();
    _endTimeFocusNode.dispose();
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

  Future<void> _createSlot() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    try {
      // Combiner la date avec les heures de début et fin
      final startTime = DateTime(
        _slotDate!.year,
        _slotDate!.month,
        _slotDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endTime = DateTime(
        _slotDate!.year,
        _slotDate!.month,
        _slotDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final slotData = {
        'coachId': _selectedCoachId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };
      final response = await CoachingSlotService.create(slotData);
      if (response.success) {
        if (mounted) {
          AppSnackBar.show(context, message: 'Créneau créé avec succès');
        }
        // Notifier la page parente que le créneau a été créé
        widget.onSlotCreated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Erreur lors de la création du créneau: $e',
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
          'Ajouter un créneau',
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
            // Sélection de la date
            AppDatePicker(
              labelText: 'Date du créneau',
              hintText: 'Quand aura lieu le créneau ?',
              prefixIcon: Icons.calendar_today,
              firstDate: DateTime.now(),
              onDateChanged: (dateTime) {
                _slotDate = dateTime;
              },
              validator: (dateTime) {
                if (dateTime == null) {
                  return 'Veuillez sélectionner une date';
                }
                if (dateTime.isBefore(DateTime.now())) {
                  return 'La date ne peut pas être dans le passé';
                }
                return null;
              },
            ),

            // Heure de début
            AppTimePicker(
              labelText: 'Heure de début',
              hintText: 'Ex: 14:00',
              prefixIcon: Icons.access_time,
              onTimeChanged: (time) {
                _startTime = time;
              },
              validator: (time) {
                if (time == null) {
                  return 'Veuillez entrer une heure de début';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Heure de fin
            AppTimePicker(
              labelText: 'Heure de fin',
              hintText: 'Ex: 15:00',
              prefixIcon: Icons.access_time,
              onTimeChanged: (time) {
                _endTime = time;
              },
              validator: (time) {
                if (time == null) {
                  return 'Veuillez entrer une heure de fin';
                }
                if (_startTime != null) {
                  final start = _startTime!;
                  if (start.hour > time.hour ||
                      (start.hour == time.hour && start.minute >= time.minute)) {
                    return 'L\'heure de fin doit être après l\'heure de début';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Sélection du coach
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
              validator: (coach) {
                if (coach == null) {
                  return 'Veuillez sélectionner un coach';
                }
                return null;
              },
            ),

            const SizedBox(height: 40),

            AppButton(
              text: 'Ajouter le créneau',
              isFullWidth: true,
              height: 50,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _createSlot,
            ),
          ],
        ),
      ),
    );
  }
}
