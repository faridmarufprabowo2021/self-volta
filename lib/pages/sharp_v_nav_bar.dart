import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

/// Item destinasi untuk tab bar iOS SELF VOLTA.
class SharpVNavItem {
  final IconData icon;
  final String label;

  const SharpVNavItem({required this.icon, required this.label});
}

/// Tab bar gaya iOS: permukaan putih, hairline atas, ikon + label kecil,
/// satu aksen (Star.star) untuk item aktif. Tanpa bentuk "V", tanpa glow.
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
      decoration: const BoxDecoration(
        color: Star.surface,
        border: Border(top: BorderSide(color: Star.lineSoft)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
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
                    highlightColor: Star.fill.withValues(alpha: .6),
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
                            fontFamily: 'Inter',
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
              );
            }),
          ),
        ),
      ),
    );
  }
}
