// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_export/home.dart';
import 'package:http/http.dart' as http;

class RepoListTile extends StatefulWidget {
  const RepoListTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  State<RepoListTile> createState() => _RepoListTileState();
}

class _RepoListTileState extends State<RepoListTile> {
  ApiStatus apiStatus = ApiStatus.initial;
  Future<void> downloadReport() async {
    apiStatus = ApiStatus.loading;
    try {
      setState(() {});
      final res = await http.get(
        Uri.parse('https://api.github.com/user/repos'),
        headers: {
          "Accept": "application/vnd.github+jso",
          'X-GitHub-Api-Version': '2022-11-28',
          "Authorization":
              "Bearer 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"
        },
      );

      final data = json.decode(res.body);
      for (var i = 0; i < data.length; i++) {}
      apiStatus = ApiStatus.success;
      setState(() {});
    } catch (e) {
      apiStatus = ApiStatus.error;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      title: Text(widget.data['name']),
      subtitle: Text(widget.data['full_name']),
      trailing: TextButton(
        child: const Text('Download report'),
        onPressed: () => downloadReport(),
      ),
    );
  }
}
