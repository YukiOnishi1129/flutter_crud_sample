import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud_sample/view/item_list_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  // Firebase初期接続
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ItemListPage(),
    );
  }
}
