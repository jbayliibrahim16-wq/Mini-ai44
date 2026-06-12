import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiUrlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _apiUrlController = TextEditingController();
    _loadApiUrl();
  }

  Future<void> _loadApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_url') ?? '';
    setState(() {
      _apiUrlController.text = savedUrl;
    });
  }

  Future<void> _saveApiUrl() async {
    if (_apiUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter API URL')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_url', _apiUrlController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API URL saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Configuration',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter your Render backend URL:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[300],
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'https://mini-ai-backend.onrender.com',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveApiUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save API URL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example URL:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[200],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'https://mini-ai-backend.onrender.com',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
