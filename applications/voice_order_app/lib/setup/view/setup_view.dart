import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Asks how to power the prototype: a live OpenAI key or the sample replay.
class SetupView extends StatefulWidget {
  const SetupView({
    required this.onApiKeySubmitted,
    required this.onSampleSelected,
    super.key,
  });

  final ValueChanged<String> onApiKeySubmitted;
  final VoidCallback onSampleSelected;

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final apiKey = _controller.text.trim();
    if (apiKey.isNotEmpty) widget.onApiKeySubmitted(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Very Yummy Coffee',
                  textAlign: TextAlign.center,
                  style: typography.sectionTitle,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Voice ordering prototype',
                  textAlign: TextAlign.center,
                  style: typography.muted.copyWith(fontSize: 16),
                ),
                SizedBox(height: spacing.huge),
                Container(
                  padding: EdgeInsets.all(spacing.xxl),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(radius.card),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('OpenAI API key', style: typography.subtitle),
                      SizedBox(height: spacing.xs),
                      Text(
                        'Used for live transcription and the Decisions API. '
                        'It stays in this tab and is gone when you reload.',
                        style: typography.muted,
                      ),
                      SizedBox(height: spacing.lg),
                      TextField(
                        controller: _controller,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        onSubmitted: (_) => _submit(),
                        style: typography.body,
                        decoration: InputDecoration(
                          hintText: 'sk-...',
                          filled: true,
                          fillColor: colors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(radius.small),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(radius.small),
                            borderSide: BorderSide(color: colors.border),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.lg),
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) => BaseButton(
                          label: 'Start ordering',
                          onPressed: _controller.text.trim().isEmpty
                              ? null
                              : _submit,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.lg),
                BaseButton(
                  label: 'Play a sample order instead',
                  variant: BaseButtonVariant.cancel,
                  onPressed: widget.onSampleSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
