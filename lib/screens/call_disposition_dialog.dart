import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/lead.dart';
import '../services/api_service.dart';

class CallDispositionDialog extends StatefulWidget {
  final Lead lead;
  final int initialDurationSeconds;

  const CallDispositionDialog({
    Key? key,
    required this.lead,
    required this.initialDurationSeconds,
  }) : super(key: key);

  @override
  State<CallDispositionDialog> createState() => _CallDispositionDialogState();
}

class _CallDispositionDialogState extends State<CallDispositionDialog> {
  late int _durationSeconds;
  String _selectedOutcome = 'Interested - Build Preview';
  final TextEditingController _notesController = TextEditingController();
  File? _selectedAudioFile;
  bool _isSubmitting = false;

  final List<String> _outcomes = [
    'Interested - Build Preview',
    'Connected - Pitch Delivered',
    'Callback Scheduled',
    'Gatekeeper Blocked',
    'Not Interested',
    'Ringing / No Answer',
    'Wrong Number',
  ];

  @override
  void initState() {
    super.initState();
    _durationSeconds = widget.initialDurationSeconds;
  }

  Future<void> _pickRecordingFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg', '3gp', 'amr'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAudioFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting audio: $e')),
      );
    }
  }

  Future<void> _submitDisposition() async {
    setState(() {
      _isSubmitting = true;
    });

    final success = await ApiService.uploadCallLog(
      leadId: widget.lead.id,
      durationSeconds: _durationSeconds,
      callOutcome: _selectedOutcome,
      notes: _notesController.text.trim(),
      clientPhone: widget.lead.phone,
      audioFile: _selectedAudioFile,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Call logged & synced to Odoo Chatter!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Log saved locally (Failed to reach n8n webhook)'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: Colors.indigo, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lead.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.lead.phone,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Duration Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Call Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(_durationSeconds ~/ 60)}m ${(_durationSeconds % 60)}s',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Outcome Selector
              const Text('Call Outcome:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOutcome,
                    isExpanded: true,
                    items: _outcomes.map((String outcome) {
                      return DropdownMenuItem<String>(
                        value: outcome,
                        child: Text(outcome, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedOutcome = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Audio Recording Attachment
              const Text('Call Recording Audio:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickRecordingFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedAudioFile != null ? Colors.green : Colors.grey[300]!,
                      width: _selectedAudioFile != null ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedAudioFile != null ? Colors.green.withOpacity(0.05) : Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedAudioFile != null ? Icons.check_circle : Icons.attach_file,
                        color: _selectedAudioFile != null ? Colors.green : Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAudioFile != null
                              ? _selectedAudioFile!.path.split(Platform.pathSeparator).last
                              : 'Select recording from phone storage',
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedAudioFile != null ? Colors.green[800] : Colors.grey[700],
                            fontWeight: _selectedAudioFile != null ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Field
              const Text('Call Notes:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Spoke with Dr. Sharma, loved the preview idea, sending WhatsApp walkthrough...',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitDisposition,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save & Sync to Odoo'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
