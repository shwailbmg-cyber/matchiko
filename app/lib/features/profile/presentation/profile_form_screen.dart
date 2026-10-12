import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matchiko/core/env.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/phone_number.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/domain/wilaya.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/badges.dart';

/// Onboarding (3 steps: who, how you play, phone) and "Edit profile"
/// (all fields on one page). Same fields, same checks.
class ProfileFormScreen extends ConsumerWidget {
  const ProfileFormScreen({super.key, required this.onboarding});

  final bool onboarding;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: onboarding
        ? null
        : AppBar(
            backgroundColor: MkColors.bg,
            title: Text(AppLocalizations.of(context).editProfile),
          ),
    body: SafeArea(
      child: AsyncView(
        ref.watch(meProvider),
        onRetry: () => ref.invalidate(meProvider),
        data: (me) => _Form(me: me, onboarding: onboarding),
      ),
    ),
  );
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.me, required this.onboarding});

  final Profile me;
  final bool onboarding;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late final _name = TextEditingController(text: widget.me.name);
  late final _phone = TextEditingController(text: _localPhone(widget.me.phone));
  late String? _wilaya = widget.me.wilayaId;
  late final _positions = [...widget.me.positions];
  late Level? _level = widget.me.level;
  int _step = 0;
  bool _showErrors = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  static String _localPhone(String? e164) =>
      e164 == null ? '' : '0${e164.substring(4)}';

  bool get _nameOk {
    final n = _name.text.trim().length;
    return n >= 2 && n <= 60;
  }

  bool get _phoneOk => algerianMobileE164(_phone.text) != null;

  bool _stepOk(int step) => switch (step) {
    0 => _nameOk && _wilaya != null,
    1 => _positions.isNotEmpty && _level != null,
    _ => _phoneOk,
  };

  Future<void> _next() async {
    final steps = widget.onboarding ? [_step] : [0, 1, 2];
    if (!steps.every(_stepOk)) {
      setState(() => _showErrors = true);
      return;
    }
    if (widget.onboarding && _step < 2) {
      setState(() {
        _step++;
        _showErrors = false;
      });
      return;
    }
    await _save();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(gameRepositoryProvider)
          .updateProfile(
            name: _name.text,
            wilayaId: _wilaya!,
            positions: _positions,
            level: _level!,
            phone: algerianMobileE164(_phone.text)!,
          );
      if (widget.onboarding) {
        router.go(Routes.home);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l.saved)));
        router.pop();
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.genericError)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sections = [_who(l), _play(l), _contact(l)];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        if (widget.onboarding) ...[
          MkTitle(l.onbTitle, size: 34),
          const SizedBox(height: 6),
          Text(l.onbSub, style: const TextStyle(color: MkColors.sub)),
          const SizedBox(height: 16),
          _Progress(step: _step, label: l.onbStep('${_step + 1}')),
          const SizedBox(height: 8),
          ...sections[_step],
        ] else
          for (final s in sections) ...s,
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : _next,
          child: Text(
            !widget.onboarding
                ? l.save
                : _step < 2
                ? l.next
                : l.letsPlay,
          ),
        ),
        if (widget.onboarding && _step > 0)
          TextButton(
            onPressed: () => setState(() => _step--),
            child: Text(l.back),
          ),
      ],
    );
  }

  /// Pick a photo, shrink it on the device, upload it (real backend only).
  Future<void> _photo({bool remove = false}) async {
    final repo = ref.read(gameRepositoryProvider);
    if (remove) return repo.setAvatar(null);
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
      requestFullMetadata: false,
    );
    if (file == null) return;
    await repo.setAvatar(await file.readAsBytes());
  }

  List<Widget> _who(AppLocalizations l) {
    final lang = Localizations.localeOf(context).languageCode;
    final w = Wilaya.byId(_wilaya);
    final photo = ref.watch(meProvider).value?.avatar;
    return [
      if (!widget.onboarding && Env.hasSupabase)
        Row(
          children: [
            MkAvatar(widget.me.initials, size: 64, photo: photo),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                children: [
                  TextButton(onPressed: _photo, child: Text(l.changePhoto)),
                  if (photo != null)
                    TextButton(
                      onPressed: () => _photo(remove: true),
                      child: Text(l.removePhoto),
                    ),
                ],
              ),
            ),
          ],
        ),
      MkLabel(l.yourName),
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        maxLength: 60,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: l.namePh,
          errorText: _showErrors && !_nameOk ? l.nameInvalid : null,
        ),
      ),
      MkLabel(l.yourWilaya),
      MkCard(
        borderColor: _showErrors && w == null ? MkColors.red : null,
        onTap: () async {
          final id = await _pickWilaya(context);
          if (id != null) setState(() => _wilaya = id);
        },
        child: Row(
          children: [
            const Icon(Icons.place_outlined, color: MkColors.sub),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                w?.label(lang) ?? l.pickWilaya,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: w == null ? MkColors.faint : MkColors.text,
                ),
              ),
            ),
            const Icon(Icons.expand_more, color: MkColors.sub),
          ],
        ),
      ),
    ];
  }

  List<Widget> _play(AppLocalizations l) => [
    MkLabel(l.yourPositions),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in Position.playable)
          FilterChip(
            selected: _positions.contains(p),
            avatar: _positions.contains(p)
                ? CircleAvatar(
                    backgroundColor: MkColors.primary,
                    child: Text(
                      '${_positions.indexOf(p) + 1}',
                      style: const TextStyle(
                        color: MkColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : Text(p.emoji),
            showCheckmark: false,
            label: Text(positionName(l, p)),
            onSelected: (_) => setState(() {
              if (!_positions.remove(p)) _positions.add(p);
              if (_positions.isEmpty) _positions.add(p);
            }),
          ),
      ],
    ),
    MkLabel(l.yourLevel),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in Level.values)
          ChoiceChip(
            selected: _level == v,
            label: Text(levelName(l, v)),
            onSelected: (_) => setState(() => _level = v),
          ),
      ],
    ),
    if (_showErrors && _level == null)
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          l.pickLevel,
          style: const TextStyle(color: MkColors.red, fontSize: 12.5),
        ),
      ),
  ];

  List<Widget> _contact(AppLocalizations l) => [
    MkLabel(l.yourPhone),
    TextField(
      controller: _phone,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: l.phonePh,
        prefixIcon: const Icon(Icons.phone_outlined, color: MkColors.faint),
        errorText: _showErrors && !_phoneOk ? l.phoneInvalid : null,
      ),
    ),
    const SizedBox(height: 8),
    Text(
      l.phoneSub,
      style: const TextStyle(color: MkColors.sub, fontSize: 12.5, height: 1.5),
    ),
  ];
}

String levelName(AppLocalizations l, Level v) => switch (v) {
  Level.beginner => l.levelBeginner,
  Level.casual => l.levelCasual,
  Level.good => l.levelGood,
  Level.competitive => l.levelCompetitive,
};

class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.label});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Container(
                height: 5,
                margin: const EdgeInsetsDirectional.only(end: 6),
                decoration: BoxDecoration(
                  color: i <= step ? MkColors.primary : MkColors.card2,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: MkColors.sub, fontSize: 12)),
    ],
  );
}

/// Searchable list of the 69 wilayas; returns the picked id.
Future<String?> _pickWilaya(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          const FractionallySizedBox(heightFactor: .85, child: _WilayaSheet()),
    );

class _WilayaSheet extends StatefulWidget {
  const _WilayaSheet();

  @override
  State<_WilayaSheet> createState() => _WilayaSheetState();
}

class _WilayaSheetState extends State<_WilayaSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final q = _q.trim().toLowerCase();
    final list = Wilaya.all
        .where(
          (w) =>
              q.isEmpty ||
              w.code.toString() == q ||
              w.nameFr.toLowerCase().contains(q) ||
              w.nameAr.contains(q),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: l.searchWilaya,
              prefixIcon: const Icon(Icons.search, color: MkColors.faint),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(list[i].label(lang)),
              onTap: () => Navigator.of(context).pop(list[i].id),
            ),
          ),
        ),
      ],
    );
  }
}
