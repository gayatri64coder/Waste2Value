import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ewaste_provider.dart';
import '../models/user_model.dart' as app_user;
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ewaste = context.watch<EWasteProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColors.primaryGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Sign Out',
                onPressed: () => _confirmSignOut(context, auth),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F5132), Color(0xFF059669)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withAlpha(80), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user?.displayName ?? 'Eco Citizen',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user?.role.label ?? 'Eco Citizen',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatCard(
                        value: Formatters.formatCredits(
                            user?.greenCredits ?? 380),
                        label: 'Green Credits',
                        icon: '🌱',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        value: '${ewaste.items.length}',
                        label: 'Items Submitted',
                        icon: '📱',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        value: Formatters.formatWeight(
                            user?.totalKgRecycled ?? 28.4),
                        label: 'Recycled',
                        icon: '♻️',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Badges
                  if (user?.badges.isNotEmpty == true) ...[
                    const _SectionLabel('Earned Badges'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (user?.badges ?? [])
                          .map((badge) => _BadgeChip(badge: badge))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Account info
                  const _SectionLabel('Account Details'),
                  const SizedBox(height: 10),
                  _InfoCard(children: [
                    _ProfileRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? '—'),
                    _ProfileRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user?.phoneNumber ?? 'Not set'),
                    _ProfileRow(
                        icon: Icons.home_outlined,
                        label: 'Default Address',
                        value: user?.defaultAddress ?? 'Not set'),
                    _ProfileRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: Formatters.formatDate(
                            user?.createdAt ?? DateTime.now())),
                  ]),
                  const SizedBox(height: 20),

                  // Dev-only role switcher
                  const _SectionLabel('Developer: Switch Demo Role'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: app_user.UserRole.values.map((role) {
                      final isCurrent = user?.role == role;
                      return GestureDetector(
                        onTap: () => auth.switchDemoRole(role),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.primaryGreen.withAlpha(20)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.primaryGreen
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Text(role.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent
                                      ? AppColors.primaryGreen
                                      : AppColors.textMuted)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Settings
                  const _SectionLabel('Settings & Help'),
                  const SizedBox(height: 10),
                  _InfoCard(children: [
                    _SettingsRow(
                        icon: Icons.notifications_outlined,
                        label: 'Push Notifications',
                        onTap: () {}),
                    _SettingsRow(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {}),
                    _SettingsRow(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {}),
                    _SettingsRow(
                        icon: Icons.info_outline_rounded,
                        label: 'About Waste2Value',
                        onTap: () => _showAbout(context)),
                  ]),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.alertRed),
                      label: const Text('Sign Out',
                          style: TextStyle(color: AppColors.alertRed)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.alertRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _confirmSignOut(context, auth),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              auth.signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Waste2Value',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Waste2Value. Circular Economy for All.',
      children: [
        const SizedBox(height: 12),
        const Text(
          'Waste2Value is an SDG-aligned e-waste management platform '
          'contributing to SDG 8, 11, 12 & 13 through certified circular '
          'economy practices.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  const _StatCard(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGreen.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primaryGreen),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amberGold.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amberGold.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: AppColors.amberGold, size: 14),
          const SizedBox(width: 5),
          Text(badge,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.amberGold)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textDark,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMuted, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textDark)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark));
  }
}
