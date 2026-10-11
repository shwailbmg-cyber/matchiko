import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/providers.dart';

/// Report a player. "Did not come" only shows when we played the same game.
Future<void> showReportSheet(
  BuildContext context, {
  required String handle,
  String? gameId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _ReportSheet(handle: handle, gameId: gameId),
);

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.handle, this.gameId});

  final String handle;
  final String? gameId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(gameRepositoryProvider)
          .reportPlayer(
            widget.handle,
            gameId: widget.gameId,
            reason: _reason!,
            note: _note.text.trim(),
          );
      nav.pop();
      messenger.showSnackBar(SnackBar(content: Text(l.reported)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.genericError)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reasons = [
      if (widget.gameId != null) (ReportReason.noShow, l.rsNoShow),
      (ReportReason.late, l.rsLate),
      (ReportReason.rude, l.rsRude),
      (ReportReason.unsafe, l.rsUnsafe),
      (ReportReason.other, l.rsOther),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.reportTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(l.reportSub, style: const TextStyle(color: MkColors.sub)),
            const SizedBox(height: 8),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v),
              child: Column(
                children: [
                  for (final (r, label) in reasons)
                    RadioListTile<ReportReason>(
                      contentPadding: EdgeInsets.zero,
                      value: r,
                      title: Text(label),
                    ),
                ],
              ),
            ),
            TextField(
              controller: _note,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(hintText: l.reportNote),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: MkColors.red),
              onPressed: _reason == null || _sending ? null : _send,
              child: Text(l.report),
            ),
          ],
        ),
      ),
    );
  }
}
