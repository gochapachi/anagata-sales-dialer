import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lead.dart';
import '../services/api_service.dart';
import 'call_disposition_dialog.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({Key? key}) : super(key: key);

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  List<Lead> _leads = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() {
      _isLoading = true;
    });

    final leads = await ApiService.fetchLeads();
    setState(() {
      _leads = leads;
      _isLoading = false;
    });
  }

  Future<void> _initiateCall(Lead lead) async {
    final sanitizedPhone = lead.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$sanitizedPhone');

    if (await canLaunchUrl(uri)) {
      _callStartTime = DateTime.now();
      await launchUrl(uri);

      // When the user returns from the native phone dialer:
      if (mounted) {
        final durationSeconds = _callStartTime != null
            ? DateTime.now().difference(_callStartTime!).inSeconds
            : 60;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => CallDispositionDialog(
            lead: lead,
            initialDurationSeconds: durationSeconds > 0 ? durationSeconds : 60,
          ),
        ).then((res) {
          if (res == true) {
            _loadLeads();
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $sanitizedPhone')),
      );
    }
  }

  Future<void> _launchWhatsApp(Lead lead) async {
    final sanitizedPhone = lead.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent(
      "Namaste! 🙏 This is Anagata IT Solutions regarding ${lead.title}. We've prepared your clinic's AI patient growth preview: https://preview.anagataitsolutions.in/demo\n\nRemember: You review first, and only pay if you love it!"
    );
    final url = Uri.parse("https://wa.me/$sanitizedPhone?text=$text");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showSettingsDialog() async {
    final currentUrl = await ApiService.getBaseUrl();
    final currentRep = await ApiService.getRepName();
    final urlCtrl = TextEditingController(text: currentUrl);
    final repCtrl = TextEditingController(text: currentRep);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dialer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'n8n Webhook Base URL',
                hintText: 'https://n8n.anagataitsolutions.in/webhook',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repCtrl,
              decoration: const InputDecoration(
                labelText: 'Sales Representative Name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.setBaseUrl(urlCtrl.text);
              await ApiService.setRepName(repCtrl.text);
              Navigator.of(ctx).pop();
              _loadLeads();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeads = _leads.where((l) {
      final q = _searchQuery.toLowerCase();
      return l.title.toLowerCase().contains(q) ||
             l.phone.contains(q) ||
             l.contactName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anagata Sales Dialer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Odoo 18 Connected Queue', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeads,
            tooltip: 'Refresh Leads',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Metrics Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.indigo.withOpacity(0.05),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search clinic, doctor name, or phone...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Leads: ${_leads.length}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Target: 60 Dials / Day',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lead Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                : filteredLeads.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in, size: 54, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No leads pending in queue!',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadLeads,
                              child: const Text('Reload from Odoo'),
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredLeads.length,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (ctx, index) {
                          final lead = filteredLeads[index];
                          return Card(
                            elevation: 1.5,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lead.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${lead.contactName} • ${lead.city}',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          lead.stage,
                                          style: const TextStyle(
                                            color: Colors.indigo,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    lead.phone,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (lead.notes.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      lead.notes,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _launchWhatsApp(lead),
                                        icon: const Icon(Icons.chat, size: 16, color: Colors.green),
                                        label: const Text('WhatsApp', style: TextStyle(color: Colors.green)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.green),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _initiateCall(lead),
                                        icon: const Icon(Icons.call, size: 16),
                                        label: const Text('Call SIM'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
