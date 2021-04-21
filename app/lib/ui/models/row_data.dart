import 'package:flutter/material.dart';

class IngredientRow {
  IngredientRow(
    this.name,
    this.consumed,
    this.lastRefill,
  );

  final String name;
  final double consumed;
  final double lastRefill;

  bool selected = false;
}

class IngredientTableData extends DataTableSource {
  IngredientTableData({this.context, this.rows});

  final BuildContext context;
  List<IngredientRow> rows;

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final row = rows[index];
    return DataRow.byIndex(
      index: index,
      selected: row.selected,
      onSelectChanged: (value) {
        debugPrint("User tapped ingredient index $index");
        // if (row.selected != value) {
        //   _selectedCount += value ? 1 : -1;
        //   assert(_selectedCount >= 0);
        //   row.selected = value;
        //   notifyListeners();
        // }
      },
      cells: [
        DataCell(Text(row.name)),
        DataCell(Text(row.consumed.toStringAsFixed(4))),
        DataCell(Text(
            ((DateTime.now().millisecondsSinceEpoch/1000 - row.lastRefill) / 86400).floor().toString()
            // row.lastRefill.toString()
        )),
      ],
    );
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
