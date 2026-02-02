import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/plan.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/glow_button.dart';
import '../widgets/gradient_card.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Plan plan;
  final String period;
  final String tradeNo;

  const OrderSuccessScreen({
    super.key,
    required this.plan,
    required this.period,
    required this.tradeNo,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Black & Silver Theme Colors
  static const Color _silverPrimary = Color(0xFFE5E7EB); // Gray 200
  static const Color _silverAccent = Color(0xFF9CA3AF);  // Gray 400
  // static const Color _silverDim = Color(0xFF4B5563);     // Gray 600

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPeriodLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'month_price': return l10n?.monthPrice ?? 'Monthly';
      case 'quarter_price': return l10n?.quarterPrice ?? 'Quarterly';
      case 'half_year_price': return l10n?.halfYearPrice ?? 'Half Yearly';
      case 'year_price': return l10n?.yearPrice ?? 'Yearly';
      case 'two_year_price': return l10n?.twoYearPrice ?? '2 Years';
      case 'three_year_price': return l10n?.threeYearPrice ?? '3 Years';
      case 'onetime_price': return l10n?.onetimePrice ?? 'One-time';
      case 'reset_price': return l10n?.resetPrice ?? 'Reset Data';
      default: return l10n?.subscription ?? 'Subscription';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure black background
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Animated Success Icon (Silver)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _silverPrimary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _silverPrimary.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: _silverPrimary,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.orderSuccess ?? 'Payment Successful',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)?.yourSubscriptionActivated ?? 'Your subscription is now active',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Order Details Card - Black & Silver Style
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Plan Name and Tag
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.purchasedPlan ?? 'Purchased Plan',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.plan.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  _getPeriodLabel(context, widget.period),
                                  style: const TextStyle(
                                    color: _silverPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Divider(color: Colors.white10),
                          ),
                          
                          // Info Rows
                          _buildInfoRow(
                            context,
                            AppLocalizations.of(context)?.traffic ?? 'Traffic',
                            Formatters.formatBytes(widget.plan.transferEnable),
                            Icons.data_usage_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            context,
                            AppLocalizations.of(context)?.order ?? 'Order ID',
                            widget.tradeNo,
                            Icons.receipt_long_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Action Button - Silver Gradient
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF3F4F6), // Gray 100
                            Color(0xFFD1D5DB), // Gray 300
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(true),
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)?.startUsing ?? 'Start Using',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
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
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _silverAccent, size: 16),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace', // Better for numbers/IDs
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
