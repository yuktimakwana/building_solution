import 'package:duplicate_building_solution/bloc/add_table_data/record_bloc.dart';
import 'package:duplicate_building_solution/bloc/add_table_data/record_event.dart';
import 'package:duplicate_building_solution/repository/record_repository.dart';
import 'package:duplicate_building_solution/screens/table/table_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({
    super.key,
    required this.partyName,
    required this.projectName,
    required this.fileName,
  });

  final String partyName;
  final String projectName;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecordsBloc(
        RecordsRepository(
          partyName: partyName,
          projectName: projectName,
          fileName: fileName,
        ),
      )..add(RecordsSubscribe()),
      child: TableDataScreen(fileName: fileName),
    );
  }
}
