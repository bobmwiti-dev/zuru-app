import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Companion tagging widget for adding friends
class CompanionTagWidget extends StatefulWidget {
  final List<String> companions;
  final ValueChanged<List<String>> onCompanionsChanged;

  const CompanionTagWidget({
    super.key,
    required this.companions,
    required this.onCompanionsChanged,
  });

  @override
  State<CompanionTagWidget> createState() => _CompanionTagWidgetState();
}

class _CompanionTagWidgetState extends State<CompanionTagWidget> {
  final TextEditingController _companionController = TextEditingController();
  bool _isExpanded = false;

  // Mock contacts for autocomplete
  final List<String> _mockContacts = [
    'Sarah Johnson',
    'Michael Chen',
    'Emily Rodriguez',
    'David Kim',
    'Jessica Williams',
    'James Anderson',
  ];

  List<String> _filteredContacts = [];

  @override
  void dispose() {
    _companionController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredContacts = []);
      return;
    }

    setState(() {
      _filteredContacts = _mockContacts
          .where((contact) =>
              contact.toLowerCase().contains(query.toLowerCase()) &&
              !widget.companions.contains(contact))
          .toList();
    });
  }

  void _addCompanion(String name) {
    if (name.trim().isEmpty || widget.companions.contains(name)) return;

    final updatedCompanions = List<String>.from(widget.companions)..add(name);
    widget.onCompanionsChanged(updatedCompanions);
    _companionController.clear();
    setState(() => _filteredContacts = []);
  }

  void _removeCompanion(String name) {
    final updatedCompanions = List<String>.from(widget.companions)
      ..remove(name);
    widget.onCompanionsChanged(updatedCompanions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'people',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Tag Companions (Optional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              CustomIconWidget(
                iconName: _isExpanded ? 'expand_less' : 'expand_more',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          SizedBox(height: 1.5.h),
          _buildCompanionInput(theme),
          if (_filteredContacts.isNotEmpty) _buildSuggestions(theme),
          if (widget.companions.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            _buildCompanionChips(theme),
          ],
        ],
      ],
    );
  }

  /// Build companion input field
  Widget _buildCompanionInput(ThemeData theme) {
    return TextField(
      controller: _companionController,
      decoration: InputDecoration(
        hintText: 'Search or add companion...',
        suffixIcon: IconButton(
          icon: CustomIconWidget(
            iconName: 'add',
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => _addCompanion(_companionController.text),
        ),
      ),
      style: theme.textTheme.bodyMedium,
      textCapitalization: TextCapitalization.words,
      onChanged: _filterContacts,
      onSubmitted: _addCompanion,
    );
  }

  /// Build autocomplete suggestions
  Widget _buildSuggestions(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      constraints: BoxConstraints(maxHeight: 20.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _filteredContacts.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final contact = _filteredContacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                contact[0],
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              contact,
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () => _addCompanion(contact),
          );
        },
      ),
    );
  }

  /// Build companion chips
  Widget _buildCompanionChips(ThemeData theme) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: widget.companions.map((companion) {
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              companion[0],
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          label: Text(
            companion,
            style: theme.textTheme.bodySmall,
          ),
          deleteIcon: CustomIconWidget(
            iconName: 'close',
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          onDeleted: () => _removeCompanion(companion),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        );
      }).toList(),
    );
  }
}
