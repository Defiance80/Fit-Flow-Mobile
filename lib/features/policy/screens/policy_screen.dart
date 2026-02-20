import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/policy/cubit/policy_cubit.dart';
import 'package:elms/features/policy/cubit/policy_state.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PolicyType { termsAndConditions, privacyPolicy }

class PolicyScreen extends StatefulWidget {
  final PolicyType policyType;

  const PolicyScreen({super.key, required this.policyType});

  static Widget route() {
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    return PolicyScreen(policyType: args['policyType'] as PolicyType);
  }

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFetched = false;

  String get _policyType {
    return widget.policyType == PolicyType.termsAndConditions
        ? 'terms-and-conditions'
        : 'privacy-policy';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFetched) {
      _controller.setBackgroundColor(context.color.surface);
      context.read<PolicyCubit>().fetchPolicySettings(type: _policyType);
      _isFetched = true;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  void _loadHtmlContent(String htmlContent) {
    final wrappedHtml =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            padding: 16px;
            margin: 0;
            color: ${_colorToHex(context.color.onSurface)};
            background-color: ${_colorToHex(context.color.surface)};
          }
          h1, h2, h3, h4, h5, h6 {
            color: ${_colorToHex(context.color.onSurface)};
          }
          a {
            color: ${_colorToHex(context.color.primary)};
          }
        </style>
      </head>
      <body>
        $htmlContent
      </body>
      </html>
    ''';

    _controller.loadHtmlString(wrappedHtml);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.policyType == PolicyType.termsAndConditions
            ? AppLabels.termsAndConditions.tr
            : AppLabels.privacyPolicy.tr,
        showBackButton: true,
      ),
      body: BlocBuilder<PolicyCubit, PolicyState>(
        builder: (context, state) {
          if (state is PolicyProgress) {
            return Center(
              child: CircularProgressIndicator(color: context.color.primary),
            );
          }
          if (state is PolicySuccess) {
            final htmlContent = state.policySettings.pageContent;

            if (_isLoading) {
              _loadHtmlContent(htmlContent);
            }

            return Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: context.color.primary,
                    ),
                  ),
              ],
            );
          }

          if (state is PolicyError) {
            return Center(
              child: Text(
                state.error,
                style: TextStyle(color: context.color.error),
                textAlign: .center,
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
