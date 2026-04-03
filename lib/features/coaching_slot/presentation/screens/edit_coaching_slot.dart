import 'package:flutter/material.dart';
import '../../data/services/coaching_slot_service.dart';
import '../../data/models/coaching_slot.dart';
import '../../../user/data/services/user_service.dart';
import '../../../user/data/models/user.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/date_picker.dart';
import '../../../../core/widgets/time_picker.dart';
import '../../../../core/widgets/generic_dropdown.dart';

class EditCoachingSlotScreen extends StatefulWidget {
  final CoachingSlot slot;
  final Function()? onSlotUpdated;

  const EditCoachingSlotScreen({
    super.key,
    required this.slot,
    this.onSlotUpdated,
  });

  @override
  State<EditCoachingSlotScreen> createState() => _EditCoachingSlotScreenState();
}

class _EditCoachingSlotScreenState extends State<EditCoachingSlotScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _slotDate;
  String? _selectedCoachId;
  List<User> _coaches = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCoaches();
  }

  void _initializeControllers() {
    _startTime = TimeOfDay(
      hour: widget.slot.startTime.hour,
      minute: widget.slot.startTime.minute,
    );
    _endTime = TimeOfDay(
      hour: widget.slot.endTime.hour,
      minute: widget.slot.endTime.minute,
    );
    _slotDate = widget.slot.startTime;
    _selectedCoachId = widget.slot.coachId;
  }

  @override
  void dispose() {
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

  Future<void> _updateSlot() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    try {
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
      final response = await CoachingSlotService.update(
        widget.slot.id,
        slotData,
      );
      if (response.success) {
        if (mounted) {
          AppSnackBar.show(context, message: 'Créneau mis à jour avec succès');
        }
        // Notifier la page parente que le créneau a été mis à jour
        widget.onSlotUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Erreur lors de la mise à jour du créneau: $e',
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
          'Modifier le créneau',
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
            AppDatePicker(
              labelText: 'Date du créneau',
              hintText: 'Quand aura lieu le créneau ?',
              prefixIcon: Icons.calendar_today,
              initialDate: _slotDate,
              onDateChanged: (dateTime) {
                _slotDate = dateTime;
              },
              validator: (dateTime) {
                if (dateTime == null) {
                  return 'Veuillez sélectionner une date';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Heure de début
            AppTimePicker(
              labelText: 'Heure de début',
              hintText: 'Ex: 14:00',
              prefixIcon: Icons.access_time,
              initialTime: _startTime,
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
              initialTime: _endTime,
              onTimeChanged: (time) {
                _endTime = time;
              },
              validator: (time) {
                if (time == null) {
                  return 'Veuillez entrer une heure de fin';
                }
                if (_startTime != null) {
                  final start = _startTime!;
                  final end = time;
                  if (start.hour > end.hour ||
                      (start.hour == end.hour && start.minute >= end.minute)) {
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
              text: 'Mettre à jour le créneau',
              isFullWidth: true,
              height: 50,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _updateSlot,
            ),
          ],
        ),
      ),
    );
  }
}
