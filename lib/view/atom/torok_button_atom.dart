import 'package:flutter/material.dart';

Widget TorokButtonAtom({Function? function}) {
  return ElevatedButton(
    onPressed: () => function?.call(),
    child: const Text('登録'),
  );
}
