import 'dart:io';
import 'dart:math' as math;
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/notice.dart';
import '../services/user_data_service.dart';
import '../services/v2ray_service.dart';
import '../theme/app_colors.dart';
import 'invite_screen.dart';
import '../widgets/fade_in_widget.dart';

class HomeDashboard extends StatefulWidget {
  final VoidCallback onConnectPressed;
  final Future<void> Function()? onReconnectRequested;
  final bool isConnected;
  final bool isConnecting;
  final String statusMessage;

  const HomeDashboard({
    super.key,
    required this.onConnectPressed,
    this.onReconnectRequested,
    required this.isConnected,
    this.isConnecting = false,
    this.statusMessage = '',
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    // 延迟检查公告
    Future.delayed(const Duration(seconds: 1), _checkNotice);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = widget.isConnecting;
    final showPulse = true; // 开启呼吸动画

    return FadeInWidget(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 800),
      offset: const Offset(0, 30),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulse, _glowController]),
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_pulse.value);
              final glowT = _glowAnimation.value;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 30,
                    ), // Resized from 60 to fit smaller screens
                    // 连接按钮容器
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          // 主阴影
                          BoxShadow(
                            color: AppColors.accent.withValues(
                              alpha: isBusy ? 0.4 : (0.2 + 0.3 * t),
                            ),
                            blurRadius: isBusy ? 40 : (35 + 25 * t),
                            spreadRadius: isBusy ? 3 : (1 + 2 * t),
                            offset: const Offset(0, 15),
                          ),
                          // 光晕效果
                          if (showPulse)
                            BoxShadow(
                              color: AppColors.accent.withValues(
                                alpha: 0.15 * t,
                              ),
                              blurRadius: 60 + 40 * t,
                              spreadRadius: 8 * t,
                              offset: const Offset(0, 10),
                            ),
                          // 动态光晕
                          BoxShadow(
                            color: AppColors.accent.withValues(
                              alpha:
                                  0.1 *
                                  (0.5 + 0.5 * math.sin(glowT * math.pi * 2)),
                            ),
                            blurRadius: 50,
                            spreadRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 柔和静态光晕，不做缩放
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.12),
                                  AppColors.accent.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // 主按钮
                          Transform.scale(
                            scale: 1.0,
                            child: _buildHeroButton(t, glowT),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 代理模式选择器 (移到连接按钮下方)
                    _buildProxyModeButton(context),

                    const SizedBox(height: 8),
                    // 状态文本 - 带打字机效果
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        widget.statusMessage,
                        key: ValueKey(widget.statusMessage),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isBusy
                              ? AppColors.accent
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // 服务优势展示
                    const SizedBox(height: 12),
                    _buildFeatureRow(context),
                    const SizedBox(height: 12),
                    _buildInviteBanner(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProxyModeButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => _showProxySettingsDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: AppColors.accent.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              l10n?.proxySettings ?? 'Proxy Mode',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showProxySettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var routingMode = V2rayService().routingMode;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curve),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 标题
                          Text(
                            l10n?.routingMode ?? 'Routing Mode',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 规则模式
                          _buildModeCard(
                            icon: Icons.alt_route_rounded,
                            title: l10n?.ruleMode ?? 'Smart',
                            isSelected: routingMode == ProxyRoutingMode.rule,
                            onTap: () async {
                              if (routingMode == ProxyRoutingMode.rule) {
                                Navigator.pop(context);
                                return;
                              }
                              V2rayService().setRoutingMode(
                                ProxyRoutingMode.rule,
                              );
                              Navigator.pop(context);
                              await _requestReconnectIfNeeded();
                            },
                          ),
                          const SizedBox(height: 10),
                          // 全局模式
                          _buildModeCard(
                            icon: Icons.public_rounded,
                            title: l10n?.globalMode ?? 'Global',
                            isSelected: routingMode == ProxyRoutingMode.global,
                            onTap: () async {
                              if (routingMode == ProxyRoutingMode.global) {
                                Navigator.pop(context);
                                return;
                              }
                              V2rayService().setRoutingMode(
                                ProxyRoutingMode.global,
                              );
                              Navigator.pop(context);
                              await _requestReconnectIfNeeded();
                            },
                          ),
                          // TUN 模式（仅桌面端）
                          if (!Platform.isAndroid && !Platform.isIOS) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.router_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n?.tunMode ?? 'TUN Mode',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          l10n?.tunModeDesc ?? 'Experimental',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatefulBuilder(
                                    builder: (context, setTunState) {
                                      var tunEnabled =
                                          V2rayService().tunEnabled;
                                      return Switch(
                                        value: tunEnabled,
                                        activeColor: AppColors.accent,
                                        onChanged: (val) async {
                                          setTunState(() => tunEnabled = val);
                                          await V2rayService().setTunEnabled(val);
                                          await _requestReconnectIfNeeded();
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestReconnectIfNeeded() async {
    if (!widget.isConnected) return;
    if (widget.onReconnectRequested != null) {
      await widget.onReconnectRequested!();
      return;
    }
    widget.onConnectPressed();
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onConnectPressed();
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withOpacity(0.35)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: AppColors.accent, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.6),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context) {
    // 使用 LayoutBuilder 响应式布局：桌面端 4 列，移动端 2 列
    return LayoutBuilder(
      builder: (context, constraints) {
        // 简单判断：如果宽度大于 600 则视为桌面/宽屏
        final isDesktop = constraints.maxWidth > 600;
        final crossAxisCount = isDesktop ? 4 : 2;
        final childAspectRatio = isDesktop ? 2.5 : 2.4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildFeatureTile(
              context,
              Icons.hub_rounded,
              AppLocalizations.of(context)?.ixpAccess ?? 'IXP Access',
              AppLocalizations.of(context)?.fastRouting ?? 'Fast Routing',
            ),
            _buildFeatureTile(
              context,
              Icons.speed_rounded,
              AppLocalizations.of(context)?.highSpeed ?? 'High Speed',
              AppLocalizations.of(context)?.instant4k ?? '4K Instant',
            ),
            _buildFeatureTile(
              context,
              Icons.security_rounded,
              AppLocalizations.of(context)?.noLogs ?? 'No Logs',
              AppLocalizations.of(context)?.privacyProtection ?? 'Privacy',
            ),
            _buildFeatureTile(
              context,
              Icons.lock_rounded,
              AppLocalizations.of(context)?.strongEncryption ?? 'Encryption',
              'AES-256',
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroButton(double t, double glowT) {
    final isBusy = widget.isConnecting;
    final l10n = AppLocalizations.of(context);
    final label = widget.isConnected
        ? (l10n?.disconnect ?? 'Disconnect')
        : (isBusy
              ? (l10n?.connecting ?? 'Connecting')
              : (l10n?.connect ?? 'Connect'));
    final icon = widget.isConnected ? Icons.power : Icons.power_settings_new;

    return GestureDetector(
      onTap: isBusy ? null : widget.onConnectPressed,
      child: SizedBox(
        width: 240,
        height: 68,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: widget.isConnected
                  ? const [Color(0xFF343A43), Color(0xFF1A1D23)]
                  : const [Color(0xFF2F3540), Color(0xFF12151B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.55),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.42),
                blurRadius: 34,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 柔和的银色光带，保持静态质感
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // 轻微呼吸感，但不改变尺寸
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, _) {
                    final glow =
                        0.06 +
                        0.04 * math.sin(_glowAnimation.value * math.pi * 2);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: glow),
                            Colors.transparent,
                          ],
                          radius: 0.9,
                          center: Alignment.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              // 状态指示点
              Positioned(
                right: 16,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isConnected
                          ? [const Color(0xFF6CFFB8), AppColors.accent]
                          : (isBusy
                                ? [
                                    const Color(0xFFFFE18D),
                                    const Color(0xFFFFB347),
                                  ]
                                : [AppColors.accent, const Color(0xFF6F7A8C)]),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isConnected
                            ? AppColors.accent.withValues(alpha: 0.5)
                            : AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkNotice() async {
    try {
      final userDataService = UserDataService();
      final data = await userDataService.getNotices();

      if (data.isEmpty) return;

      // 取最新的一条公告
      final latestNotice = Notice.fromJson(data.first);

      final prefs = await SharedPreferences.getInstance();
      final lastReadId = prefs.getInt('last_read_notice_id') ?? 0;

      if (latestNotice.id > lastReadId) {
        if (!mounted) return;
        _showNoticeDialog(latestNotice);
      }
    } catch (e) {
      debugPrint('Fetching notice failed: $e');
    }
  }

  Widget _buildInviteBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InviteScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.2),
              AppColors.accent.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.inviteFriendsTitle ?? '邀请有礼',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)?.inviteFriendsSubtitle ??
                        '邀请好友加入，获取丰厚奖励',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _showNoticeDialog(Notice notice) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox(); // 这里的 builder 不重要，主要看 transitionBuilder
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 使用弹簧曲线
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: LogNoticeDialog(notice: notice),
            ),
          ),
        );
      },
    );
  }
}

class LogNoticeDialog extends StatelessWidget {
  final Notice notice;

  const LogNoticeDialog({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: AppColors.accent.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
            border: Border.all(
              color: AppColors.accent.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部图片或装饰
              if (notice.imgUrl != null && notice.imgUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.network(
                    notice.imgUrl!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 20),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      size: 32,
                      color: AppColors.accent,
                    ),
                  ),
                ),

              // 标题和内容
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Text(
                      notice.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Text(
                          notice.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 按钮
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('last_read_notice_id', notice.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.accent.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)?.gotIt ?? '我知道了',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
