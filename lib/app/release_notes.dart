import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'build_info.dart';

const build4ReleaseNotes = [
  'Responsive navigation and centered layouts for tablets and web.',
  'A diagnostics screen with build, database, data, and connection status.',
  'Health Connect sync controls, permission status, and manage-access tools.',
  'Optional Open Food Facts barcode lookup with an on-device cache.',
  'Release notes that identify what changed in each installed build.',
];

class ReleaseNotesGate extends StatefulWidget {
  const ReleaseNotesGate({super.key, required this.child});

  final Widget child;

  @override
  State<ReleaseNotesGate> createState() => _ReleaseNotesGateState();
}

class _ReleaseNotesGateState extends State<ReleaseNotesGate> {
  static const _lastSeenKey = 'last_seen_release_build';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIfNeeded());
  }

  Future<void> _showIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    final lastSeen = preferences.getInt(_lastSeenKey) ?? 0;
    if (lastSeen >= AppBuildInfo.buildNumber || !mounted) return;
    await preferences.setInt(_lastSeenKey, AppBuildInfo.buildNumber);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('What’s new in Build 4'),
        content: SizedBox(width: 440, child: ReleaseNotesBody()),
        actions: [_CloseReleaseNotesButton()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ReleaseNotesScreen extends StatelessWidget {
  const ReleaseNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('What’s new')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [ReleaseNotesBody()],
          ),
        ),
      ),
    );
  }
}

class ReleaseNotesBody extends StatelessWidget {
  const ReleaseNotesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppBuildInfo.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final note in build4ReleaseNotes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(note)),
              ],
            ),
          ),
      ],
    );
  }
}

class _CloseReleaseNotesButton extends StatelessWidget {
  const _CloseReleaseNotesButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Got it'),
    );
  }
}
