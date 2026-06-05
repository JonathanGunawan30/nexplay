import 'dart:io' show Platform;
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as win;
import 'package:web/web.dart' as web;

class PlayGameScreen extends StatefulWidget {
  final String title;
  final String gameUrl;

  const PlayGameScreen({super.key, required this.title, required this.gameUrl});

  @override
  State<PlayGameScreen> createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends State<PlayGameScreen> {
  WebViewController? _mobileController;
  
  final _winController = win.WebviewController();
  
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
        final String viewId = 'iframe-${widget.gameUrl.hashCode}';
        
        ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
          return web.HTMLIFrameElement()
            ..src = widget.gameUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true;
        });
        
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      } else if (Platform.isWindows) {
        try {
          await _winController.initialize();
          await _winController.setPopupWindowPolicy(win.WebviewPopupWindowPolicy.deny);
          await _winController.loadUrl(widget.gameUrl);
          
          _winController.loadingState.listen((state) {
            if (state == win.LoadingState.navigationCompleted) {
              if (mounted) setState(() => _isLoading = false);
            }
          });
          
          setState(() => _isInitialized = true);
        } catch (e) {
          setState(() => _initError = "WebView2 Runtime may be missing on your Windows. Error: $e");
        }
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
      setState(() => _initError = "Initialization error: $e");
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && Platform.isWindows) {
      _winController.dispose();
    }
    super.dispose();
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
            
          if (_isLoading && _initError == null && !kIsWeb)
            const Center(child: CircularProgressIndicator(color: Colors.indigoAccent)),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    if (kIsWeb) {
      final String viewId = 'iframe-${widget.gameUrl.hashCode}';
      return HtmlElementView(viewType: viewId);
    }
    
    if (Platform.isWindows) {
      return win.Webview(_winController);
    }
    
    if (_mobileController != null) {
      return WebViewWidget(controller: _mobileController!);
    }
    
    return const Center(child: Text('WebView not available', style: TextStyle(color: Colors.white)));
  }
}
