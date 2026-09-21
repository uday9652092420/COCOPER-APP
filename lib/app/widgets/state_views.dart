import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/exceptions.dart';
import '../theme/app_theme.dart';

class LoadingCards extends StatelessWidget {
  const LoadingCards({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0EA),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFEDF6E8),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 30,
                  color: CocoperColors.teal,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'nothing_here'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'nothing_here_hint'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (onAction != null) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text('create_entry'.tr),
                ),
              ],
            ],
          ),
        ),
      );
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is AppException
        ? (error as AppException).message.tr
        : 'something_went_wrong'.tr;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: CocoperColors.coral,
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
