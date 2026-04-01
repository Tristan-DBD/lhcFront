import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../../../core/storage/supabase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/message_service.dart';
import '../../data/services/program_service.dart';
import '../../../../core/utils/file_saver/file_saver.dart';

class ProgrammePage extends StatefulWidget {
  const ProgrammePage({
    required this.user,
    super.key,
    this.onProgramsUpdated,
    this.isManager = false,
  });

  final User user;
  final bool isManager;
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Programme',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section programmes existants
            AppCard(
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_programs.isEmpty)
                      Text(
                        'Pas de programme',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _programs.length,
                        itemBuilder: (context, index) {
                          final program = _programs[index];
                          final programName = _formatProgramName(
                            program['name'] ?? 'Programme ${index + 1}',
                          );
                          return ListTile(
                            title: Text(
                              programName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.download,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  onPressed: () => _showDownloadConfirmation(
                                    program['fileUri'] ?? program['name'],
                                  ),
                                ),
                                if (widget.isManager)
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    onPressed: () => _showDeleteConfirmation(
                                      program['name'],
                                    ),
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
            if (widget.isManager)
              AppCard(
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: _isLoading
                            ? 'Téléchargement...'
                            : 'Choisir un fichier Excel',
                        isFullWidth: true,
                        onPressed: _isLoading ? null : _pickAndUploadFile,
                      ),
                    ],
                  ),
                ),
              ),
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

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) {
        setState(() => _isLoading = false);
        return;
      }

      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      final String? token = await _getToken();

      if (token == null) {
        setState(() {
          _isLoading = false;
        });

        MessageService.showError(
          context,
          'Erreur: Token d\'authentification non trouvé',
        );
        return;
      }

      final response = await _programService.uploadProgram(
        widget.user.id,
        fileBytes,
        fileName,
      );

      if (response.success) {
        setState(() {
          _isLoading = false;
        });

        // Recharger les programmes depuis le serveur pour avoir la liste à jour
        await _loadPrograms();

        // Afficher le message de succès en Snackbar
        MessageService.showSuccess(
          context,
          'Programme téléchargé avec succès!',
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        // Afficher le message d'erreur en Snackbar
        MessageService.showError(
          context,
          'Erreur lors du téléchargement: ${response.errorMessage}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Afficher le message d'erreur en Snackbar
      MessageService.showError(context, 'Erreur: $e');
    }
  }

  Future<void> _deleteProgram(String? fileName) async {
    if (fileName == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final String? token = await _getToken();

      if (token == null) {
        setState(() {
          _isLoading = false;
        });

        MessageService.showError(
          context,
          'Erreur: Token d\'authentification non trouvé',
        );
        return;
      }

      final response = await _programService.deleteProgram(
        widget.user.id,
        fileName,
      );

      if (response.success) {
        setState(() {
          _isLoading = false;
        });

        // Recharger les programmes depuis le serveur pour avoir la liste à jour
        await _loadPrograms();

        MessageService.showSuccess(context, 'Programme supprimé avec succès!');
      } else {
        setState(() {
          _isLoading = false;
        });

        MessageService.showError(
          context,
          'Erreur lors de la suppression: ${response.errorMessage}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      MessageService.showError(context, 'Erreur: $e');
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
      final String? token = await _getToken();

      if (token != null) {
        // Récupérer les programmes depuis le serveur pour avoir les données à jour
        final response = await _programService.getPrograms(widget.user.id);

        if (response.success == true) {
          if (response.data != null) {
            final List<Map<String, dynamic>> serverPrograms = [];

            for (var item in response.data!) {
              if (item is Map) {
                // Le backend enveloppe les données dans un champ 'message'
                final messageData = item['message'];

                if (messageData is List) {
                  // Cas où 'message' contient la liste des programmes
                  for (var prog in messageData) {
                    if (prog is Map) {
                      final map = Map<String, dynamic>.from(prog);
                      if (map['name'] != null || map['fileUri'] != null) {
                        serverPrograms.add(map);
                      }
                    }
                  }
                } else if (item['name'] != null || item['fileUri'] != null) {
                  // Cas où l'item lui-même est un programme (sécurité)
                  serverPrograms.add(Map<String, dynamic>.from(item));
                }
              }
            }

            setState(() {
              _programs = serverPrograms;
            });

            widget.onProgramsUpdated?.call(_programs);
            return;
          }
        } else {}
      }
    } catch (e) {
      // Ignore errors during server data fetching
    }

    // En cas d'erreur ou si pas de données serveur, utiliser les données locales filtrées

    setState(() {
      final List<Map<String, dynamic>> localPrograms = [];
      for (var p in widget.user.progUri) {
        if (p['name'] != null || p['fileUri'] != null) {
          localPrograms.add(p);
        }
      }
      _programs = localPrograms;
    });
  }

  void _showDeleteConfirmation(String? fileName) {
    if (fileName == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer le programme "${_formatProgramName(fileName)}" ?',
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProgram(fileName);
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
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
          title: const Text('Confirmer le téléchargement'),
          content: Text(
            'Voulez-vous télécharger le programme "${_formatProgramName(fileName)}" ?',
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadProgram(fileName);
              },
              child: Text(
                'Télécharger',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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

      // Télécharger le fichier depuis Supabase
      Uint8List? fileBytes;

      if (kIsWeb) {
        // Sur le web, télécharger directement les bytes
        fileBytes = await _storageService.downloadProgramBytes(fileUri);
      } else {
        // Sur mobile/desktop, utiliser le fichier temporaire existant
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName';
        final file = await _storageService.downloadProgramFile(
          fileUri,
          tempPath,
        );

        if (file != null) {
          fileBytes = await file.readAsBytes();
          // Supprimer le fichier temporaire
          await file.delete();
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (fileBytes != null) {
        // Laisser l'utilisateur choisir où sauvegarder le fichier
        final String? outputPath = await FileSaver.saveFile(
          fileName: fileName,
          bytes: fileBytes,
        );

        if (outputPath != null) {
          MessageService.showSuccess(
            context,
            'Programme sauvegardé avec succès dans $outputPath',
          );
        } else {
          MessageService.showInfo(context, 'Sauvegarde annulée');
        }
      } else {
        MessageService.showError(
          context,
          'Erreur lors du téléchargement: fichier non trouvé',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      MessageService.showError(context, 'Erreur: $e');
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
