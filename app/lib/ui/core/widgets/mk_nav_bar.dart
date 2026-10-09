import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/mk_colors.dart';

class MkNavItem {
  const MkNavItem(this.icon, this.label, {this.diamond = false});

  final IconData icon;
  final String label;

  /// The center Play button: a lime rotated square raised above the bar.
  final bool diamond;
}

/// Bottom navigation from the prototype (`#nav`, 86px, 4 columns).
class MkNavBar extends StatelessWidget {
  const MkNavBar({
    super.key,
    required this.items,
    required this.current,
    required this.onTap,
  });

  final List<MkNavItem> items;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MkColors.nav,
        border: Border(top: BorderSide(color: MkColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _button(items[i], i == current, () => onTap(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(MkNavItem item, bool on, VoidCallback tap) {
    final color = on ? MkColors.lime : MkColors.faint;
    final label = Text(
      item.label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    );
    return Semantics(
      button: true,
      selected: on,
      label: item.label,
      child: InkResponse(
        onTap: tap,
        child: item.diamond
            ? Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -17),
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: MkColors.lime,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: MkColors.lime.withValues(alpha: .35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            const BoxShadow(
                              color: MkColors.nav,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: Icon(item.icon, color: MkColors.ink, size: 24),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: label,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: color, size: 23),
                  const SizedBox(height: 3),
                  label,
                ],
              ),
      ),
    );
  }
}
