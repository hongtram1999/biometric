import 'package:biometric/services/local_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

late  WebViewController webViewController;

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            String subUrl = "https://zonar-dev.auth0.com/login?";
            if(url.contains(subUrl)){
              webViewController.runJavaScript('''
                const btnId = document.getElementsByClassName('login-header');
                // document.getElementsByClassName('auth0-label-submit')[0].innerHTML = "Production";
                console.log("Luan from Login button", btnId);
                btnId[0].addEventListener("click", myFunction, false);
                function myFunction() {
                console.log("Luan from Login button 1");
                testReceiveFromWeb.postMessage('Login success');
                }
                // btnId.innerText = 'Hello';
              ''');
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'testReceiveFromWeb',
        onMessageReceived: (JavaScriptMessage message) async {
          String msg = message.message;
          print("Luan message $msg");
          bool isAuthenticated =
              await LocalAuthService.authenticateWithBiometrics();
          if (isAuthenticated) {
            print("Luan Authenticated");
            webViewController.loadRequest(Uri.parse('https://guileless-chaja-0526a7.netlify.app?bio=true'));
          }
          // Navigator.pop(context);
        },
      )
      ..addJavaScriptChannel(
        'testPushFromFlutter',
        onMessageReceived: (JavaScriptMessage message) {
          String msg = message.message;
          print("Luan message $msg");
        },
      )
      ..loadRequest(Uri.parse('https://guileless-chaja-0526a7.netlify.app/'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
    webViewController = controller;
    Future.delayed(const Duration(seconds: 2), () {
      // webViewController.runJavaScript('updateIsMobileApp(true)');
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: WebViewWidget(
          controller: webViewController),

    );
  }
}
