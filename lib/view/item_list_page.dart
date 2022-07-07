import 'package:flutter/material.dart';
import 'package:flutter_crud_sample/view_model/item_list_view_model.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../model/item_model.dart';

// riverpodとhooksの機能を合わせて使う場合、HookConsumerWidgetを使用
// http://dav.blog.jp/archives/10376012.html
// https://crieit.net/posts/Riverpod-v1-Flutter-Hooks
class ItemListPage extends HookConsumerWidget {
  // コンストラクタ
  const ItemListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // state(状態)
    // ref.watchでproviderを読み取る
    final itemList = ref.watch(itemListProvider);
    // provider(状態の操作)
    final itemListNotifier = ref.watch(itemListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD APP'),
      ),
      // itemList = AsyncValue
      // AsyncValueのwhenメソッドを使用することで、データの取得時、ローディング時、エラー時の3つの処理を書くことができる
      body: itemList.when(
        data: (items) => items.isEmpty
            ? const Center(
                child: Text(
                  'タスクがありません。',
                  style: TextStyle(fontSize: 20.0),
                ),
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  String getTodayDate() {
                    initializeDateFormatting('ja');
                    return DateFormat('yyyy/MM/dd HH:mm', "ja")
                        .format(item.createdAt);
                  }

                  return ProviderScope(
                    child: Dismissible(
                      key: ValueKey(item.id),
                      background: Container(
                        color: Colors.red,
                      ),
                      onDismissed: (_) {
                        // データの削除
                        itemListNotifier.deleteItem(
                          itemId: item.id!, // 削除するidの指定
                        );
                      },
                      child: Column(
                        children: [
                          ListTile(
                            key: ValueKey(item.id),
                            title: Text(item.title),
                            subtitle: Text(
                              getTodayDate(),
                            ),
                            trailing: Checkbox(
                              value: item.isCompleted,
                              // Checkboxの値を書き換える
                              onChanged: (_) => itemListNotifier.updateItem(
                                updateItem: item.copyWith(
                                  isCompleted: !item.isCompleted,
                                ),
                              ),
                            ),
                            // タスク作成ダイアログを表示する
                            onTap: () => AddItemDialog.show(context, item),
                          ),
                          const Divider(
                            height: 2,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(), // ローディング時
        ),
        error: (error, _) => Text(
          error.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // タスク作成時ダイアログを表示する(追加)
        onPressed: () => AddItemDialog.show(
          context,
          Item.empty(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// タスクダイアログ
class AddItemDialog extends HookConsumerWidget {
  static void show(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(item: item),
    );
  }

  final Item item;
  const AddItemDialog({Key? key, required this.item}) : super(key: key);
  // 追加 or 更新の判定を行う
  bool get isUpdating => item.id != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初期値にタイトルを入れておく
    // HookConsumerWidgetを継承しているので、hooksが使える
    final textController = useTextEditingController(text: item.title);
    // provider(状態の操作)
    final itemListNotifier = ref.watch(itemListProvider.notifier);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'タイトル'),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: isUpdating
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  isUpdating
                      ? itemListNotifier.updateItem(
                          // データの更新
                          updateItem: item.copyWith(
                          title: textController.text.trim(),
                        ))
                      : itemListNotifier.addItem(
                          // データの追加
                          title: textController.text.trim(),
                        );
                },
                child: Text(isUpdating ? '更新' : '追加'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
