import 'package:flutter/material.dart';
import 'package:frontend/data/bottom_bar.data.dart';

class BottomBarPage extends StatefulWidget {
  final List<BottomBarData> items;
  final int checkedItem;
  final Color selectedColor;
  final Color backgroundColor;
  final VoidCallback? onBack;

  BottomBarData getCurrentItem(int index) {
    return items.elementAt(index);
  }

  const BottomBarPage({
    super.key,
    this.items = const [],
    this.checkedItem = 0,
    this.selectedColor = Colors.blue,
    this.backgroundColor = Colors.black87,
    this.onBack,
  });

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  int _currentIndex = 0;

  BottomBarData _getCurrentItem(int index) {
    return widget.items.elementAt(index);
  }

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final BottomBarData selectedItem = _getCurrentItem(_currentIndex);

    final Color barBackgroundColor = selectedItem.color != null
        ? Color.alphaBlend(widget.backgroundColor, selectedItem.color!)
        : widget.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: widget.onBack,
          child: const Icon(Icons.arrow_back_sharp),
        ),
        title: Text(selectedItem.label),
      ),
      body: Center(
        child: selectedItem.content,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: widget.items.map((BottomBarData item) {
          return BottomNavigationBarItem(
            icon: item.icon,
            label: item.label,
            backgroundColor: item.color,
          );
        }).toList(),
        currentIndex: _currentIndex,
        selectedItemColor: widget.selectedColor,
        unselectedItemColor: Colors.grey,
        onTap: _onTap,
        backgroundColor: barBackgroundColor,
      ),
    );
  }
}
