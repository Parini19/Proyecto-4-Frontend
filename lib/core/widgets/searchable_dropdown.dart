import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// A searchable dropdown widget that displays items in a popup overlay with search functionality
/// Similar to Material's mat-select with search capability
class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final bool enabled;
  final String? Function(T?)? validator;

  const SearchableDropdown({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.enabled = true,
    this.validator,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  void _showSearchDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMD,
        ),
        child: _SearchableDropdownDialog<T>(
          items: widget.items,
          itemLabel: widget.itemLabel,
          currentValue: widget.value,
          onSelected: (value) {
            widget.onChanged(value);
            Navigator.pop(context);
          },
          label: widget.label,
          isDark: isDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.enabled ? () => _showSearchDialog(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: widget.enabled
              ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
              : (isDark ? AppColors.darkSurfaceVariant.withOpacity(0.5) : AppColors.lightSurfaceVariant.withOpacity(0.5)),
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(
                widget.prefixIcon,
                color: widget.enabled
                    ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                    : AppColors.textDisabled,
              ),
              SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Text(
                    widget.label,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Selected value or hint
                  Text(
                    widget.value != null
                        ? widget.itemLabel(widget.value as T)
                        : (widget.hint ?? 'Seleccionar...'),
                    style: AppTypography.bodyLarge.copyWith(
                      color: widget.value != null
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: widget.enabled
                  ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                  : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchableDropdownDialog<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final T? currentValue;
  final void Function(T) onSelected;
  final String label;
  final bool isDark;

  const _SearchableDropdownDialog({
    required this.items,
    required this.itemLabel,
    required this.currentValue,
    required this.onSelected,
    required this.label,
    required this.isDark,
  });

  @override
  State<_SearchableDropdownDialog<T>> createState() => _SearchableDropdownDialogState<T>();
}

class _SearchableDropdownDialogState<T> extends State<_SearchableDropdownDialog<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final label = widget.itemLabel(item).toLowerCase();
          return label.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Title
          Text(
            widget.label,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Search field
          TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _filterItems,
            style: AppTypography.bodyLarge.copyWith(
              color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _filterItems('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: widget.isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSM,
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Items list
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: widget.isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'No se encontraron resultados',
                          style: AppTypography.bodyLarge.copyWith(
                            color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                    child: ListView.separated(
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item == widget.currentValue;

                        return ListTile(
                          title: Text(
                            widget.itemLabel(item),
                            style: AppTypography.bodyLarge.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : (widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check, color: AppColors.primary)
                              : null,
                          selected: isSelected,
                          selectedTileColor: AppColors.primary.withOpacity(0.1),
                          onTap: () => widget.onSelected(item),
                          dense: true,
                        );
                      },
                    ),
                  ),
          ),

          SizedBox(height: AppSpacing.md),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}
