import 'dart:convert';
import 'dart:io';

import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String orderNumber;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderNumber,
  });

  static Widget route([RouteSettings? settings]) {
    final args = (settings?.arguments ?? Get.arguments) as Map<String, dynamic>;
    return PaymentWebViewScreen(
      paymentUrl: args['paymentUrl'] as String,
      orderNumber: args['orderNumber'] as String,
    );
  }

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<String> getInnerText(WebViewController controller) async {
    final text = await controller.runJavaScriptReturningResult(
      "document.querySelector('pre')?.innerText || document.body.innerText",
    );

    // The result comes as a JSON string, remove quotes and unescape
    String textString = text.toString();

    // Remove leading and trailing quotes if present
    if (textString.startsWith('"') && textString.endsWith('"')) {
      textString = textString.substring(1, textString.length - 1);
    }

    // Unescape Unicode characters (e.g., \u003C -> <)
    textString = textString.replaceAllMapped(
      RegExp(r'\\u([0-9a-fA-F]{4})'),
      (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
    );

    // Unescape other special characters
    textString = textString
        .replaceAll(r'\/', '/')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\\', '\\');

    return textString.trim();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _handleUrlChange(url);
          },
          onHttpError: (HttpResponseError error) {
            // _showErrorDialog('HTTP Error: ${error.response?.statusCode}');
          },
          onWebResourceError: (WebResourceError error) {},
          onHttpAuthRequest: (HttpAuthRequest request) {
            // Handle HTTP authentication if needed
          },
          onUrlChange: (UrlChange change) async {
            if (change.url?.contains('razorpay/callback') ?? false) {
              final String response = await getInnerText(_controller);
              final decode = json.decode(response) as Map<String, dynamic>;
              final PaymentGatewayCallbackResponse result =
                  PaymentGatewayCallbackResponse.fromJson(
                    decode['data'] as Map<String, dynamic>,
                  );

              if (mounted) {
                Navigator.pop(context, result);
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.containsAny([
              'stripe-callback',

              'flutterwave-callback',
            ])) {
              final Map<String, dynamic> response = await Api.get(request.url);

              final PaymentGatewayCallbackResponse result =
                  PaymentGatewayCallbackResponse.fromJson(response['data']);
              if (mounted) {
                Navigator.pop(context, result);
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));

    // Configure iOS-specific SSL handling
    if (Platform.isIOS) {
      final wkController = _controller.platform as WebKitWebViewController;
      wkController.setAllowsBackForwardNavigationGestures(true);
    }
  }

  void _handleUrlChange(String url) {
    if (url.contains('success') ||
        url.contains('payment_intent_client_secret')) {
      _onPaymentSuccess();
    } else if (url.contains('cancel') || url.contains('cancelled')) {
      _onPaymentCancelled();
    }
  }

  void _onPaymentSuccess() {
    Get.back(result: {'success': true, 'orderNumber': widget.orderNumber});
  }

  void _onPaymentCancelled() {
    Get.back(result: {'success': false, 'cancelled': true});
  }

  Future<void> _handleBackPress() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      await _controller.goBack();
    } else {
      _showCancelDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await _handleBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: context.color.surface,
        appBar: CustomAppBar(
          title: AppLabels.payment.tr,
          showBackButton: true,
          onTapBack: () async {
            await _handleBackPress();
          },
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: context.color.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      CircularProgressIndicator(color: context.color.primary),
                      const SizedBox(height: 16),
                      Text(
                        AppLabels.loadingPayment.tr,
                        style: TextStyle(
                          color: context.color.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLabels.cancelPayment.tr),
        content: Text(AppLabels.cancelPaymentMessage.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLabels.no.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onPaymentCancelled();
            },
            child: Text(AppLabels.yes.tr),
          ),
        ],
      ),
    );
  }
}

class PaymentGatewayCallbackResponse {
  final int orderId;
  final String orderNumber;
  final PaymentStatus status;
  final String transactionId;
  final num amount;
  final String redirectUrl;

  PaymentGatewayCallbackResponse({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.transactionId,
    required this.amount,
    required this.redirectUrl,
  });

  factory PaymentGatewayCallbackResponse.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayCallbackResponse(
      orderId: json['order_id'] is String
          ? int.parse(json['order_id'])
          : json['order_id'],
      orderNumber: json['order_number'],
      status: PaymentStatus.from(json['status']),
      transactionId: json['transaction_id'],
      amount: json['amount'] is String
          ? num.parse(json['amount'])
          : json['amount'],
      redirectUrl: json['redirect_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'status': status.value,
      'transaction_id': transactionId,
      'amount': amount,
      'redirect_url': redirectUrl,
    };
  }
}
