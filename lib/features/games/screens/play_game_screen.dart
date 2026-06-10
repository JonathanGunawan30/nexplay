import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlayGameScreen extends StatefulWidget {
  final String title;
  final String gameUrl;

  const PlayGameScreen({super.key, required this.title, required this.gameUrl});

  @override
  State<PlayGameScreen> createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends State<PlayGameScreen> {
  WebViewController? _mobileController;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      if (kIsWeb) {
        // Web platform — HtmlElementView handled via separate web-only file
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      } else {
        _mobileController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                if (mounted) setState(() => _isLoading = false);
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.gameUrl));
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      setState(() => _initError = 'Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_initError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(_initError!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
              ),
            )
          else if (_isInitialized)
            _buildWebView()
          else
            const Center(child: CircularProgressIndicator(color: Colors.indigoAccent)),
          if (_isLoading && _initError == null)
            const Center(child: CircularProgressIndicator(color: Colors.indigoAccent)),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    if (_mobileController != null) {
      return WebViewWidget(controller: _mobileController!);
    }
    return const Center(
      child: Text('WebView not available', style: TextStyle(color: Colors.white)),
    );
  }
}