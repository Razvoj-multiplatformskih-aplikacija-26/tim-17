import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key, required this.jobId});

  final JobPostingId jobId;

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _letter = TextEditingController();
  bool _touched = false;

  @override
  void dispose() {
    _letter.dispose();
    super.dispose();
  }

  Result<MotivationLetter> get _parsed => MotivationLetter.parse(_letter.text);

  String? get _error => _touched ? _parsed.errorOrNull?.message : null;

  void _submit() {
    setState(() => _touched = true);
    if (_parsed case Success(:final value)) {
      context.read<JobsBloc>().add(ApplyRequested(widget.jobId, value));
    }
  }

  void _onNotice(BuildContext context, JobsNotice notice) {
    final messenger = ScaffoldMessenger.of(context);
    context.read<JobsBloc>().add(const JobsNoticeAcknowledged());
    switch (notice) {
      case ApplicationSubmitted(:final record):
        context.read<MyApplicationsBloc>().add(const MyApplicationsRefreshed());
        messenger.showSnackBar(const SnackBar(content: Text('Prijava je poslata.')));
        context.go('/applications/${record.id.value}', extra: true);
      case ApplicationRejected(:final error):
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      case ApplicationFailed():
        messenger.showSnackBar(
          const SnackBar(content: Text('Prijava nije poslata. Proveri internet vezu i pokušaj ponovo.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<JobsBloc, JobsState>(
      listenWhen: (previous, current) => current is JobsReady && current.notice?.jobId == widget.jobId,
      listener: (context, state) => _onNotice(context, (state as JobsReady).notice!),
      builder: (context, state) {
        final job = state is JobsReady ? state.find(widget.jobId) : null;
        final sending = state is JobsReady && state.isApplying(widget.jobId);
        final length = _letter.text.trim().characters.length;
        return Scaffold(
          appBar: AppBar(title: const Text('Prijava na oglas')),
          body: ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 32 + MediaQuery.paddingOf(context).bottom),
            children: [
              if (job != null) ...[
                Text(job.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text(
                  '${job.employerName} · ${job.city}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
              ],
              TextField(
                controller: _letter,
                enabled: !sending,
                minLines: 6,
                maxLines: 12,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() => _touched = true),
                decoration: InputDecoration(
                  labelText: 'Motivaciono pismo',
                  alignLabelWithHint: true,
                  hintText: 'Napiši zašto si dobar izbor za ovaj posao.',
                  helperText: 'Od ${MotivationLetter.minLength} do ${MotivationLetter.maxLength} znakova.',
                  errorText: _error,
                  counterText: '$length/${MotivationLetter.maxLength}',
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: sending
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())
                    : GradientButton(onPressed: _submit, icon: Icons.send_rounded, label: 'Pošalji prijavu'),
              ),
            ],
          ),
        );
      },
    );
  }
}
