import 'package:flutter/material.dart';
import 'package:lhc_front/constant/app_colors.dart';
import 'package:lhc_front/models/User.dart';

class ProgrammePage extends StatefulWidget {
  const ProgrammePage({super.key, required this.user});

  final User user;

  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Programme'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(child: Text('Programme Page')),
    );
  }
}
