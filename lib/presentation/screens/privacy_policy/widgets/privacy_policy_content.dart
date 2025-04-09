import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/presentation/static/static_variables.dart';


class PrivacyPolicyContent extends StatefulWidget{
  final void Function()? onScrolledDown;

  const PrivacyPolicyContent({super.key, this.onScrolledDown});
  
  @override
  State<StatefulWidget> createState() {
    return _PrivacyPolicyContentState();
  }
}

class _PrivacyPolicyContentState extends State<PrivacyPolicyContent>{
  final ScrollController _scrollController = ScrollController();
  String htmlContent = '';

  @override
  void initState() {
    super.initState();
    fetchHtmlContent();
    _scrollController.addListener((){
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && widget.onScrolledDown != null){
        widget.onScrolledDown!();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Html(data: htmlContent)
              )
            );
  }

  void fetchHtmlContent() async {
   await _loadPrivacyPolicy('/privacy-policy/${StaticVariables.lang}.html');
  }

  Future<void> _loadPrivacyPolicy(String url) async {
    try {
      final apiUrl = await GetStorage().read('apiUrl');
      final response = await http.get(
          Uri.parse(apiUrl + url));
      if (response.statusCode == 200) {
        setState(() {
          htmlContent = utf8.decode(response.bodyBytes);
        });
      }

      if (response.statusCode == 404 && url != '/privacy-policy/en.html') {
        await _loadPrivacyPolicy('/privacy-policy/en.html');
      }
    } catch (e) {
      Sentry.captureException(e);
    }
  }
}