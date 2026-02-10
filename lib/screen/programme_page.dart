import 'package:flutter/material.dart';
import 'package:lhc_front/constant/app_colors.dart';
import 'package:lhc_front/models/User.dart';
import 'package:lhc_front/services/program.dart';
import 'package:lhc_front/services/supabase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class ProgrammePage extends StatefulWidget {
  const ProgrammePage({super.key, required this.user, this.onProgramsUpdated});

  final User user;
  final Function(List<Map<String, dynamic>>)? onProgramsUpdated;

  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  final ProgramService _programService = ProgramService();
  final SupabaseStorageService _storageService = SupabaseStorageService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _programs = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Programme'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section programmes existants
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes programmes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_programs.isEmpty)
                      Text(
                        'Aucun programme téléchargé',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _programs.length,
                        itemBuilder: (context, index) {
                          final program = _programs[index];
                          final programName = _formatProgramName(
                            program['name'] ?? 'Programme ${index + 1}',
                          );
                          return ListTile(
                            title: Text(
                              programName,
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.download,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () => _showDownloadConfirmation(
                                    program['fileUri'] ?? program['name'],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteConfirmation(program['name']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section upload nouveau programme
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajouter un programme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickAndUploadFile,
                      icon: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.upload_file),
                      label: Text(
                        _isLoading
                            ? 'Téléchargement...'
                            : 'Choisir un fichier Excel',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Messages d'erreur ou succès (remplacés par des SnackBars)
            // Cette section est maintenant gérée par des SnackBars directement dans les méthodes
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _isLoading = false);
        return;
      }

      File file = File(result.files.single.path!);

      String? token = await _getToken();

      if (token == null) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Token d\'authentification non trouvé'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      final response = await _programService.uploadProgram(
        widget.user.id,
        file,
        token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });

        // Recharger les programmes depuis le serveur pour avoir la liste à jour
        await _loadPrograms();

        // Afficher le message de succès en Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Programme téléchargé avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        // Afficher le message d'erreur en Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: ${response.body}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Afficher le message d'erreur en Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _deleteProgram(String? fileName) async {
    if (fileName == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      String? token = await _getToken();

      if (token == null) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Token d\'authentification non trouvé'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      final response = await _programService.deleteProgram(
        widget.user.id,
        fileName,
        token,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _isLoading = false;
        });

        // Recharger les programmes depuis le serveur pour avoir la liste à jour
        await _loadPrograms();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Programme supprimé avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: ${response.body}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadPrograms() async {
    try {
      String? token = await _getToken();

      if (token != null) {
        // Récupérer les programmes depuis le serveur pour avoir les données à jour
        final response = await _programService.getPrograms(
          widget.user.id,
          token,
        );

        if (response.statusCode == 200) {
          // Parser la réponse JSON - le serveur retourne {"success":true,"data":[{"message":[...]}]}
          final responseData = jsonDecode(response.body);

          if (responseData['success'] == true &&
              responseData['data'] is List &&
              responseData['data'].isNotEmpty &&
              responseData['data'][0]['message'] is List) {
            final List<dynamic> programsData =
                responseData['data'][0]['message'];
            final List<Map<String, dynamic>> serverPrograms = programsData
                .map((item) => item as Map<String, dynamic>)
                .toList();

            setState(() {
              _programs = serverPrograms;
            });

            // Notifier le parent des changements
            widget.onProgramsUpdated?.call(_programs);
            return;
          } else {
            print('Structure de réponse inattendue: $responseData');
          }
        } else {
          print('Erreur HTTP: ${response.statusCode}, Body: ${response.body}');
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des programmes depuis le serveur: $e');
    }

    // En cas d'erreur, utiliser les données locales de l'utilisateur
    setState(() {
      _programs = List.from(widget.user.progUri);
    });
  }

  void _showDeleteConfirmation(String? fileName) {
    if (fileName == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer le programme "${_formatProgramName(fileName)}" ?',
          ),
          backgroundColor: AppColors.surface,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProgram(fileName);
              },
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDownloadConfirmation(String? fileName) {
    if (fileName == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer le téléchargement'),
          content: Text(
            'Voulez-vous télécharger le programme "${_formatProgramName(fileName)}" ?',
          ),
          backgroundColor: AppColors.surface,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadProgram(fileName);
              },
              child: Text(
                'Télécharger',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadProgram(String fileUri) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Extraire le nom de fichier du fileUri
      final fileName = fileUri.split('/').last;

      // Télécharger le fichier depuis Supabase d'abord dans un temporaire
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';

      final file = await _storageService.downloadProgramFile(fileUri, tempPath);

      setState(() {
        _isLoading = false;
      });

      if (file != null) {
        // Laisser l'utilisateur choisir où sauvegarder le fichier
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Sauvegarder le programme',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx', 'xls'],
          bytes: await file.readAsBytes(),
        );

        if (outputPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Programme sauvegardé avec succès dans $outputPath'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sauvegarde annulée'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Supprimer le fichier temporaire
        await file.delete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: fichier non trouvé'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  String _formatProgramName(String fileName) {
    // Si le nom est un timestamp, le convertir en date lisible
    if (RegExp(r'^\d{13}$').hasMatch(fileName)) {
      try {
        final timestamp = int.parse(fileName);
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return 'Programme du ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        return fileName;
      }
    }

    // Si le nom contient un timestamp avec extension
    final timestampMatch = RegExp(r'(\d{13})').firstMatch(fileName);
    if (timestampMatch != null) {
      try {
        final timestamp = int.parse(timestampMatch.group(1)!);
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final extension = fileName.contains('.')
            ? fileName.substring(fileName.lastIndexOf('.'))
            : '';
        return 'Programme du ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}$extension';
      } catch (e) {
        return fileName;
      }
    }

    // Sinon retourner le nom original
    return fileName;
  }
}
