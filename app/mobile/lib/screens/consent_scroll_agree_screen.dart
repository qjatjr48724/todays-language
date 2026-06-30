import 'package:flutter/material.dart';

import '../services/analytics/analytics_action_log.dart';
import '../l10n/app_localizations.dart';


/// 스크롤로 전문을 끝까지 확인한 뒤에만 동의할 수 있는 약관·개인정보 전문 화면.
class ConsentScrollAgreeScreen extends StatefulWidget {
    const ConsentScrollAgreeScreen({
        super.key,
        required this.title,
        required this.version,
        required this.body,
        this.readOnly = false,
    });


    final String title;
    final String version;
    final String body;

    /// true면 동의 버튼 없이 열람만 (이미 동의한 경우).
    final bool readOnly;


    @override
    State<ConsentScrollAgreeScreen> createState() =>
        _ConsentScrollAgreeScreenState();
}


class _ConsentScrollAgreeScreenState extends State<ConsentScrollAgreeScreen> {
    static const double _scrollbarThickness = 8;

    final ScrollController _scrollController = ScrollController();
    bool _scrolledToEnd = false;


    @override
    void initState() {
        super.initState();
        _scrollController.addListener(_syncScrollReached);
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollReached());
    }


    @override
    void dispose() {
        _scrollController.removeListener(_syncScrollReached);
        _scrollController.dispose();
        super.dispose();
    }


    void _syncScrollReached() {
        if (!_scrollController.hasClients) return;
        _updateScrollReached(_scrollController.position);
    }


    void _updateScrollReached(ScrollMetrics metrics) {
        final reached = isConsentScrollComplete(
            pixels: metrics.pixels,
            maxScrollExtent: metrics.maxScrollExtent,
        );
        if (reached == _scrolledToEnd || !mounted) return;
        setState(() => _scrolledToEnd = reached);
    }


    @override
    Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
            appBar: AppBar(
                title: Text(widget.title),
            ),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Expanded(
                        child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            interactive: true,
                            thickness: _scrollbarThickness,
                            radius: const Radius.circular(10),
                            child: NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                    if (notification.metrics.axis ==
                                        Axis.vertical) {
                                        _updateScrollReached(
                                            notification.metrics,
                                        );
                                    }
                                    return false;
                                },
                                child: SingleChildScrollView(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.fromLTRB(
                                        24,
                                        16,
                                        24,
                                        24,
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                l10n
                                                    .consent_document_version_label(
                                                  widget.version,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge
                                                    ?.copyWith(
                                                      color: scheme.outline,
                                                    ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                                widget.body.trim(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ),
                    ),
                    if (!widget.readOnly && _scrolledToEnd)
                        _buildAgreeFooter(context, l10n, scheme),
                ],
            ),
        );
    }


    Widget _buildAgreeFooter(
        BuildContext context,
        AppLocalizations l10n,
        ColorScheme scheme,
    ) {
        return Material(
            elevation: 8,
            color: scheme.surface,
            child: SafeArea(
                top: false,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: FilledButton(
                        onPressed: () {
                            logConsentComplete();
                            Navigator.of(context).pop(true);
                        },
                        child: Text(l10n.consent_scroll_agree_button),
                    ),
                ),
            ),
        );
    }
}


/// 전문 스크롤이 끝에 도달했는지 판별 (짧은 본문은 즉시 true).
bool isConsentScrollComplete({
    required double pixels,
    required double maxScrollExtent,
    double threshold = 32,
}) {
    return maxScrollExtent <= 0 || pixels >= maxScrollExtent - threshold;
}
