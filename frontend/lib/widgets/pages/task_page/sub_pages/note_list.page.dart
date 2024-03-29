import 'package:flutter/material.dart';
import 'package:frontend/models/note.dart';
import 'package:frontend/widgets/cards/note.card.dart';
import 'package:frontend/widgets/dialogs/note.dialog.dart';
import 'package:provider/provider.dart';

import '../../../../di/app.module.dart';
import '../../../../view_models/note.view_model.dart';
import '../../../components/list.component.dart';

class NoteListPage extends StatelessWidget {
  const NoteListPage({super.key});

  Future<void> Function() _showDialog(BuildContext context, {Note? note}) {
    return () async {
      final viewModel = context.read<NoteViewModel>();

      viewModel.setNote(note);

      await showDialog(
        context: context,
        builder: (BuildContext ctx) => NoteDialog.onCreate(viewModel),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteViewModel>();

    return ListComponent(
      isLoading: viewModel.isLoading,
      items: viewModel
          .getNotes()
          .map(
            (Note note) => NoteCard(
              note: note,
              onEdit: _showDialog(context, note: note),
              onDelete: viewModel.deleteById(note.id),
            ),
          )
          .toList(),
      placeholder: 'Нет заметок',
      onAdd: _showDialog(context),
    );
  }

  static Widget onCreate() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => injector.get<NoteViewModel>(param1: context).create(),
      child: const NoteListPage(),
    );
  }
}
