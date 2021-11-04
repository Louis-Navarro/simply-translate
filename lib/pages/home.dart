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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../widgets/list_view_search.dart';

const languages = <String>[
  'Afrikaans',
  'Albanian',
  'Amharic',
  'Arabic',
  'Armenian',
  'Azerbaijani',
  'Basque',
  'Belarusian',
  'Bengali',
  'Bosnian',
  'Bulgarian',
  'Catalan',
  'Cebuano',
  'Chichewa',
  'Chinese',
  'Corsican',
  'Croatian',
  'Czech',
  'Danish',
  'Dutch',
  'English',
  'Esperanto',
  'Estonian',
  'Filipino',
  'Finnish',
  'French',
  'Frisian',
  'Galician',
  'Georgian',
  'German',
  'Greek',
  'Gujarati',
  'Haitian Creole',
  'Hausa',
  'Hawaiian',
  'Hebrew',
  'Hindi',
  'Hmong',
  'Hungarian',
  'Icelandic',
  'Igbo',
  'Indonesian',
  'Irish',
  'Italian',
  'Japanese',
  'Javanese',
  'Kannada',
  'Kazakh',
  'Khmer',
  'Kinyarwanda',
  'Korean',
  'Kurdish (Kurmanji)',
  'Kyrgyz',
  'Lao',
  'Latin',
  'Latvian',
  'Lithuanian',
  'Luxembourgish',
  'Macedonian',
  'Malagasy',
  'Malay',
  'Malayalam',
  'Maltese',
  'Maori',
  'Marathi',
  'Mongolian',
  'Myanmar (Burmese)',
  'Nepali',
  'Norwegian',
  'Odia (Oriya)',
  'Pashto',
  'Persian',
  'Polish',
  'Portuguese',
  'Punjabi',
  'Romanian',
  'Russian',
  'Samoan',
  'Scots Gaelic',
  'Serbian',
  'Sesotho',
  'Shona',
  'Sindhi',
  'Sinhala',
  'Slovak',
  'Slovenian',
  'Somali',
  'Spanish',
  'Sundanese',
  'Swahili',
  'Swedish',
  'Tajik',
  'Tamil',
  'Tatar',
  'Telugu',
  'Thai',
  'Turkish',
  'Turkmen',
  'Ukrainian',
  'Urdu',
  'Uyghur',
  'Uzbek',
  'Vietnamese',
  'Welsh',
  'Xhosa',
  'Yiddish',
  'Yoruba',
  'Zulu',
];

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({Key? key}) : super(key: key);

  @override
  _TranslatorPageState createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  static const double padding = 8.0;

  static const String api = "simplytranslate.org";
  Timer? _debounce;

  TextEditingController inputTextController = TextEditingController();
  TextEditingController outputTextController = TextEditingController();
  bool error = false;
  late String from;
  late String to;

  late final AudioPlayer audioPlayerInput;
  late final AudioPlayer audioPlayerOutput;

  bool swaping = false;

  void _translateText(String text) {
    _debounce?.cancel();
    if (text == '') {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        outputTextController.text = '';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final String link = _getLink(text);
      final url = Uri.parse(link);
      final req = await http.get(url);
      if (req.statusCode == 200) {
        outputTextController.text = req.body;
        audioPlayerInput.setUrl(
          _getTtsLink(from, inputTextController.text).toString(),
        );
        audioPlayerOutput.setUrl(
          _getTtsLink(to, outputTextController.text).toString(),
        );
        setState(() {
          error = false;
        });
      } else {
        outputTextController.text = 'Error';
        print(req.body);
        setState(() {
          error = true;
        });
      }
    });
  }

  String _getLink(String text, {String engine = 'google'}) {
    return Uri.https(api, 'api/translate',
        {'from': from, 'to': to, 'engine': engine, 'text': text}).toString();
    // return '$apiLink/translate?from=$from&to=$to&text=$text&engine=$engine';
  }

  Uri _getTtsLink(String lang, String text, {engine = 'google'}) {
    return Uri.https(
        api, 'api/tts', {'lang': lang, 'engine': engine, 'text': text});
    // return '$apiLink/tts?lang=$lang&text=$text&engine=$engine';
  }

  void _swapLanguages() {
    if (swaping) return;
    setState(() {
      swaping = true;
    });

    String temp = inputTextController.text;
    inputTextController.text = outputTextController.text;
    outputTextController.text = temp;

    temp = from;
    from = to;
    to = temp;

    setState(() {
      _translateText(inputTextController.text);
      swaping = false;
    });
  }

  @override
  void initState() {
    audioPlayerInput = AudioPlayer();
    audioPlayerOutput = AudioPlayer();
    from = 'English';
    to = 'French';
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    audioPlayerInput.dispose();
    audioPlayerOutput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(padding / 2),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    child: Text(from),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.85,
                          // minChildSize: 0.6,
                          // maxChildSize: 0.9,
                          expand: false,
                          builder: (context, scroll) => SeachListView(
                            options: languages,
                            func: (String value) {
                              setState(() {
                                if (value == to) {
                                  _swapLanguages();
                                  return;
                                }
                                from = value;
                              });
                              _translateText(inputTextController.text);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => _swapLanguages(),
                    icon: const Icon(Icons.swap_horiz_rounded),
                  ),
                  TextButton(
                    child: Text(to),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.85,
                          // minChildSize: 0.6,
                          // maxChildSize: 0.9,
                          expand: false,
                          builder: (context, scroll) => SeachListView(
                            options: languages,
                            func: (String value) {
                              setState(() {
                                if (value == from) {
                                  _swapLanguages();
                                  return;
                                }
                                to = value;
                              });
                              _translateText(inputTextController.text);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        flex: 4,
                        child: SizedBox(
                          child: TextField(
                            maxLines: null,
                            controller: inputTextController,
                            expands: true,
                            onChanged: (value) {
                              // print(value);
                              _translateText(value);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Text to translate',
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
                                    text: inputTextController.text,
                                  ),
                                ).then((_) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Copied initial text to clipboard'),
                                    duration: Duration(milliseconds: 500),
                                  ));
                                });
                              },
                              icon: const Icon(Icons.copy),
                            ),
                            IconButton(
                              onPressed: () async {
                                await audioPlayerInput.play();
                                audioPlayerInput.stop();
                              },
                              icon: const Icon(Icons.volume_up),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        flex: 4,
                        child: TextField(
                          controller: outputTextController,
                          maxLines: null,
                          expands: true,
                          style: TextStyle(
                              color: error ? Colors.red : Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Translated Text',
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
                                    text: outputTextController.text,
                                  ),
                                ).then((_) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Copied translation to clipboard'),
                                    duration: Duration(milliseconds: 500),
                                  ));
                                });
                              },
                              icon: const Icon(Icons.copy),
                            ),
                            IconButton(
                              onPressed: () async {
                                await audioPlayerOutput.play();
                                audioPlayerOutput.stop();
                              },
                              icon: const Icon(Icons.volume_up),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
