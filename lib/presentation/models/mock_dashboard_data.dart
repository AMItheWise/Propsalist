import 'package:flutter/material.dart';

import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';

class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
}

class MockProposalCard {
  const MockProposalCard({
    required this.title,
    required this.client,
    required this.status,
    required this.updated,
    required this.statusColor,
    required this.leading,
  });

  final String title;
  final String client;
  final String status;
  final String updated;
  final Color statusColor;
  final String leading;
}

class SettingsTileData {
  const SettingsTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.status,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? status;
}

const dashboardStats = [
  DashboardStat(
    label: 'Proposals',
    value: '12',
    helper: '+20% vs last week',
    icon: Icons.trending_up,
  ),
  DashboardStat(
    label: 'Clarifications',
    value: '3',
    helper: 'Needs your input',
    icon: Icons.help_outline,
  ),
  DashboardStat(
    label: 'Saved Profiles',
    value: '6',
    helper: 'Active profiles',
    icon: Icons.person_outline,
  ),
  DashboardStat(
    label: 'Drafts',
    value: '8',
    helper: 'In progress',
    icon: Icons.edit_document,
  ),
];

const mockProposals = [
  MockProposalCard(
    title: 'Website Redesign Proposal',
    client: 'Acme Inc.',
    status: 'In Progress',
    updated: '2h ago',
    statusColor: ProposalistColors.primary,
    leading: 'R',
  ),
  MockProposalCard(
    title: 'Mobile App Development RFP',
    client: 'Bright Labs',
    status: 'Completed',
    updated: '1d ago',
    statusColor: ProposalistColors.success,
    leading: 'D',
  ),
  MockProposalCard(
    title: 'SaaS Platform Proposal',
    client: 'CloudScale',
    status: 'Draft',
    updated: '2d ago',
    statusColor: ProposalistColors.textSecondary,
    leading: 'S',
  ),
  MockProposalCard(
    title: 'Marketing Strategy Proposal',
    client: 'Growthly',
    status: 'Archived',
    updated: '5d ago',
    statusColor: ProposalistColors.textSecondary,
    leading: 'G',
  ),
  MockProposalCard(
    title: 'UI/UX Design Services',
    client: 'Productly',
    status: 'In Review',
    updated: '1w ago',
    statusColor: ProposalistColors.warning,
    leading: 'U',
  ),
  MockProposalCard(
    title: 'Data Analytics Solution',
    client: 'DataCore',
    status: 'Completed',
    updated: '2w ago',
    statusColor: ProposalistColors.success,
    leading: 'G',
  ),
  MockProposalCard(
    title: 'AI Chatbot Integration',
    client: 'HelpDesk Pro',
    status: 'Draft',
    updated: '2w ago',
    statusColor: ProposalistColors.textSecondary,
    leading: 'U',
  ),
];

const settingsTiles = [
  SettingsTileData(
    title: 'OpenAI API',
    subtitle: 'Model, API key, and connection status.',
    icon: Icons.auto_awesome,
    status: 'Connected',
  ),
  SettingsTileData(
    title: 'Firebase (Firestore)',
    subtitle: 'Project and profile storage connection.',
    icon: Icons.cloud_queue,
    status: 'Configured',
  ),
  SettingsTileData(
    title: 'Mock Mode',
    subtitle: 'Use mock data when services are unavailable.',
    icon: Icons.toggle_on_outlined,
    status: 'Enabled',
  ),
  SettingsTileData(
    title: 'Appearance',
    subtitle: 'System, light, dark, and primary color.',
    icon: Icons.palette_outlined,
  ),
  SettingsTileData(
    title: 'Privacy & Data',
    subtitle: 'Analytics, crash reports, and retention.',
    icon: Icons.lock_outline,
  ),
];
