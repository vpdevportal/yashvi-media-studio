import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/logo_section.dart';
import '../widgets/status_card.dart';
import '../widgets/connection_button.dart';
import '../widgets/platform_pills.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  String _serverStatus = 'Tap to check connection';
  bool _isLoading = false;
  bool _isConnected = false;

  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _pingServer() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.ping();
      setState(() {
        _isConnected = response.statusCode == 200;
        _serverStatus = _isConnected 
            ? 'Connected • Server Online' 
            : 'Error ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _serverStatus = 'Offline • Connection Failed';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(rotateController: _rotateController),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    LogoSection(pulseController: _pulseController),
                    const SizedBox(height: 80),
                    StatusCard(
                      serverStatus: _serverStatus,
                      isConnected: _isConnected,
                    ),
                    const SizedBox(height: 24),
                    ConnectionButton(
                      isLoading: _isLoading,
                      onPressed: _pingServer,
                    ),
                    const SizedBox(height: 60),
                    const PlatformPills(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

