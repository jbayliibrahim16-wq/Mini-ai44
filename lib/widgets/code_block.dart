import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlock extends StatefulWidget {
  final String content;
  final bool isUser;

  const CodeBlock({
    Key? key,
    required this.content,
    required this.isUser,
  }) : super(key: key);

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  String _extractCode(String content) {
    final regex = RegExp(r'```[\w]*\n([\s\S]*?)\n```');
    final match = regex.firstMatch(content);
    if (match != null) {
      return match.group(1) ?? content;
    }
    return content;
  }

  String _getLanguage(String content) {
    final regex = RegExp(r'```([\w]+)');
    final match = regex.firstMatch(content);
    return match?.group(1) ?? 'code';
  }

  void _copyCode() {
    final code = _extractCode(widget.content);
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final code = _extractCode(widget.content);
    final language = _getLanguage(widget.content);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _copyCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _copied ? Colors.green : Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _copied ? 'Copied!' : 'Copy',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                code,
                style: TextStyle(
                  color: Colors.green[300],
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
