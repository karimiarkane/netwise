import 'package:flutter/material.dart';
import 'package:ra9mana/views/maps_page.dart';

class PageBuilder extends StatefulWidget {
  const PageBuilder({super.key});

  @override
  State<PageBuilder> createState() => _PageBuilderState();
}

class _PageBuilderState extends State<PageBuilder> {
  final List<Widget> _pages = [
    const Center(child: Text('Page 1')),
    const Center(child: MapsPage()),
    const Center(child: Text('Page 3')),
  ];
  final _controller = PageController();
  int _activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          _activeIndex = value;
          setState(() {
            _controller.animateToPage(value,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeIn);
          });
        },
        currentIndex: _activeIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
