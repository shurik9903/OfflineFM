import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/notifier/option_notifier.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';

import 'package:provider/provider.dart';

Future pageOpen(BuildContext context, Widget widget) {
  final radio = context.read<RadioNotifier>();
  final player = context.read<OptionNotifier>();

  return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: radio,
                  ),
                  ChangeNotifierProvider.value(
                    value: player,
                  ),
                ],
                builder: (context, child) => widget,
              )));
}

MultiProvider dialogOpen(BuildContext context, Widget widget) {
  final radio = context.read<RadioNotifier>();
  final player = context.read<OptionNotifier>();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: radio,
      ),
      ChangeNotifierProvider.value(
        value: player,
      ),
    ],
    builder: (context, child) => widget,
  );
}
