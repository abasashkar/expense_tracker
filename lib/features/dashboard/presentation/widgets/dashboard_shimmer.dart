import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.surfaceLight,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _box(height: 100)),
              const SizedBox(width: 12),
              Expanded(child: _box(height: 100)),
            ],
          ),
          const SizedBox(height: 16),
          _box(height: 100),
          const SizedBox(height: 24),
          ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _box(height: 72),
              )),
        ],
      ),
    );
  }

  Widget _box({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
