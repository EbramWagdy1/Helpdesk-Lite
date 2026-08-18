import 'package:flutter/material.dart';
import 'package:helpdesk/core/services/connectivity_service.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';

class NoInternet404Widget extends StatefulWidget {
  final VoidCallback? onRetry;
  final String? message;
  final bool isFullScreen;

  const NoInternet404Widget({
    super.key,
    this.onRetry,
    this.message,
    this.isFullScreen = true,
  });

  @override
  State<NoInternet404Widget> createState() => _NoInternet404WidgetState();
}

class _NoInternet404WidgetState extends State<NoInternet404Widget>
    with TickerProviderStateMixin {
  bool _isChecking = false;
  AnimationController? _pulseController;
  AnimationController? _rotateController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    if (_pulseController != null && _rotateController != null) return;

    _pulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _rotateController ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOutSine),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAnimations();
  }

  @override
  void didUpdateWidget(covariant NoInternet404Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimations();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _rotateController?.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final connectivityService = sl.isRegistered<ConnectivityService>()
        ? sl<ConnectivityService>()
        : ConnectivityService();

    final isConnected = await connectivityService.isConnected();

    if (mounted) {
      setState(() => _isChecking = false);

      if (isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: const Row(
              children: [
                Icon(Icons.wifi_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Connection restored! You are back online.',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
        widget.onRetry?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: const Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Still offline. Please check your network connection.',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();
    final AnimationController pulseCtrl = _pulseController!;
    final AnimationController rotateCtrl = _rotateController!;
    final Animation<double> pulseAnim = _pulseAnimation!;
    final Animation<double> glowAnim = _glowAnimation!;

    final content = Stack(
      children: [
        // Background subtle ambient gradients
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.08),
                  const Color(0xFFEF4444).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Main Content Area
        Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. HERO 3D ILLUSTRATION WITH 404 & RADAR EFFECT
                AnimatedBuilder(
                  animation: pulseCtrl,
                  builder: (context, child) {
                    final glowAnimVal = glowAnim.value;
                    return ScaleTransition(
                      scale: pulseAnim,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ambient pulse wave
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEF4444).withValues(
                                alpha: 0.04 * glowAnimVal,
                              ),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withValues(
                                  alpha: 0.12 * glowAnimVal,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),

                          // Middle radar wave
                          Container(
                            width: 175,
                            height: 175,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEF4444).withValues(alpha: 0.06),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                                width: 1.5,
                              ),
                            ),
                          ),

                          // Inner Card Box with 404 watermark & wifi icon
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFF1F5F9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Subtle 404 watermark in the background
                                Text(
                                  '404',
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.5,
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                  ),
                                ),
                                // Glowing Wi-Fi Off Icon
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFDC2626),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Orbiting mini signal dot
                          RotationTransition(
                            turns: rotateCtrl,
                            child: Container(
                              width: 200,
                              height: 200,
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // 2. STATUS PILL BADGE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'HTTP 404 • NO CONNECTION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. HEADLINE
                Text(
                  'Please Check Your Internet',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // 4. SUBTITLE DESCRIPTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.message ??
                        'We couldn\'t connect to the server. Please verify your Wi-Fi router or cellular data connection.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 5. TROUBLESHOOTING CHECKLIST CARD
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Troubleshooting Tips:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCheckItem(
                        icon: Icons.wifi_rounded,
                        text: 'Verify Wi-Fi network is active',
                      ),
                      const SizedBox(height: 8),
                      _buildCheckItem(
                        icon: Icons.cell_tower_rounded,
                        text: 'Check mobile cellular data signal',
                      ),
                      const SizedBox(height: 8),
                      _buildCheckItem(
                        icon: Icons.airplanemode_inactive_rounded,
                        text: 'Ensure Airplane mode is turned off',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 6. ACTION BUTTON
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                    onPressed: _isChecking ? null : _handleRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1D4ED8),
                            Color(0xFF2563EB),
                            Color(0xFF3B82F6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: _isChecking
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Reconnecting...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 22, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Try Again',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.isFullScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  Widget _buildCheckItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
