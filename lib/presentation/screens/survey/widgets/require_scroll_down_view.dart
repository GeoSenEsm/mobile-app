import 'package:flutter/material.dart';

class RequireScrollDownView extends StatefulWidget {
  final Widget child;
  final void Function()? onScrolledDown;

  const RequireScrollDownView(
      {super.key, required this.child, this.onScrolledDown});

  @override
  State<StatefulWidget> createState() {
    return _RequireScrollDownViewState();
  }
}

class _RequireScrollDownViewState extends State<RequireScrollDownView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent == 0 &&
          widget.onScrolledDown != null) {
        widget.onScrolledDown!();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          widget.onScrolledDown != null) {
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
    return SingleChildScrollView(
        controller: _scrollController, child: widget.child);
  }
}
