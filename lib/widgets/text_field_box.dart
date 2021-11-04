// Copyright (C) 2021 Louis-Navarro
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:just_audio/just_audio.dart';
import 'package:ionicons/ionicons.dart';

class TextFieldBox extends StatefulWidget {
  final TextEditingController textController;
  final AudioPlayer audioPlayer;
  final void Function(String)? translateText;

  final String hintText;
  final String snackBarMessage;

  final bool enabled;

  const TextFieldBox({
    required this.textController,
    required this.audioPlayer,
    this.translateText,
    Key? key,
    this.enabled = true,
    required this.hintText,
    required this.snackBarMessage,
  }) : super(key: key);

  @override
  _TextFieldBoxState createState() => _TextFieldBoxState();
}

class _TextFieldBoxState extends State<TextFieldBox> {
  late final TextEditingController textController;
  late final AudioPlayer audioPlayer;
  late final void Function(String) translateText;

  late final String hintText;
  late final String snackBarMessage;

  late final bool enabled;

  @override
  void initState() {
    textController = widget.textController;
    audioPlayer = widget.audioPlayer;
    translateText = widget.translateText ?? (_) {};

    hintText = widget.hintText;
    snackBarMessage = widget.snackBarMessage;

    enabled = widget.enabled;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 4,
          child: SizedBox(
            child: TextField(
              maxLines: null,
              enabled: enabled,
              controller: textController,
              expands: true,
              onChanged: (value) {
                // print(value);
                translateText(value);
              },
              decoration: InputDecoration(
                hintText: hintText,
                suffixIcon: Align(
                  alignment: Alignment.topRight,
                  widthFactor: 1.0,
                  heightFactor: 10.0,
                  child: enabled
                      ? IconButton(
                          icon: const Icon(Ionicons.close, size: 28),
                          onPressed: () {
                            textController.clear();
                            translateText(textController.text);
                          },
                        )
                      : const SizedBox(),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: textController.text,
                    ),
                  ).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(snackBarMessage),
                      duration: const Duration(milliseconds: 500),
                    ));
                  });
                },
                icon: const Icon(Ionicons.copy_outline),
              ),
              IconButton(
                onPressed: () async {
                  await audioPlayer.play();
                  audioPlayer.stop();
                },
                icon: const Icon(Ionicons.volume_high_outline),
              ),
            ],
          ),
        )
      ],
    );
  }
}
