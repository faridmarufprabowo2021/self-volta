import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

/// Item destinasi untuk tab bar iOS SELF VOLTA.
class SharpVNavItem {
  final IconData icon;
  final String label;

  const SharpVNavItem({required this.icon, required this.label});
}

/// Tab bar neumorphic: panel timbul dengan sudut atas membulat; item aktif
/// "tertekan" ke dalam sumur cekung dengan ikon & label beraksen.
class SharpVBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<SharpVNavItem> items;

  const SharpVBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Star.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Neu.shadowDark.withValues(alpha: .9),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Neu.shadowLight.withValues(alpha: .5),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62 + (MediaQuery.textScalerOf(context).scale(1) - 1) * 14,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: item.label,
                  child: InkWell(
                    onTap: () {
                      iosTapBuzz();
                      onItemSelected(index);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 7,
                      ),
                      decoration: isSelected
                          ? Neu.well(r: 16)
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 23,
                            color: isSelected ? Star.star : Star.faint,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10.5,
                              height: 1.0,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              letterSpacing: -0.1,
                              color: isSelected ? Star.star : Star.faint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
