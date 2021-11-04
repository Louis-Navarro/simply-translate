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

class SeachListView extends StatefulWidget {
  final List<String> options;
  final void Function(String) func;

  const SeachListView({required this.options, required this.func, Key? key})
      : super(key: key);

  @override
  _SeachListViewState createState() => _SeachListViewState();
}

class _SeachListViewState extends State<SeachListView> {
  late final List<String> options;
  late List<String> showLanguages;
  late final void Function(String) func;

  @override
  void initState() {
    func = widget.func;
    options = widget.options;
    showLanguages = options;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            onChanged: (String value) {
              showLanguages = options
                  .where((lang) =>
                      lang.toLowerCase().startsWith(value.toLowerCase()))
                  .toList();
              setState(() => {});
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search for a language',
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: showLanguages.length,
              itemBuilder: (context, int index) {
                final String value = showLanguages[index];
                return TextButton(
                  onPressed: () => func(value),
                  style: const ButtonStyle(
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, inx) {
                return const Divider();
              },
            ),
          ),
        ],
      ),
    );
  }
}
