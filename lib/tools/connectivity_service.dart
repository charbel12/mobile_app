import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  final _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityResult>.broadcast();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _controller.add(result);
    });
  }

  Stream<ConnectivityResult> get connectivityStream => _controller.stream;

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;

  const ConnectivityWrapper({
    Key? key,
    required this.child,
    this.offlineWidget,
  }) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivityService.connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      _showConnectivitySnackBar(result);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    bool isOnline = await _connectivityService.isOnline();
    setState(() {
      _isOnline = isOnline;
    });
  }

  void _showConnectivitySnackBar(ConnectivityResult result) {
    if (!mounted) return;

    final message = result == ConnectivityResult.none
        ? 'You are offline'
        : 'Your connection has been restored';

    final backgroundColor =
        result == ConnectivityResult.none ? Colors.red : Colors.green;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline && widget.offlineWidget != null) {
      return widget.offlineWidget!;
    }
    return widget.child;
  }
}
