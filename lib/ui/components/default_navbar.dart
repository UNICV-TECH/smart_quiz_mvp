import 'package:flutter/material.dart';

class Preview extends StatelessWidget {
  final String name;
  const Preview({super.key, required this.name});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});
  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

@Preview(name: 'Custom NavBar')
Widget customNavBarPreview() {
  return const CustomNavBarTest();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;
  final double _circleSize = 70.0;
  final double _navBarHeight = 110.0;
  final Color _navBarColor = const Color(0xFF38553A);
  final double _curveDepth = 24.0;
  final double _shoulder = 28.0;
  final double _gap = 18.0;
  final Duration _anim = const Duration(milliseconds: 520);
  final List<Map<String, dynamic>> _items = const [
    {'icon': Icons.home, 'label': 'Início'},
    {'icon': Icons.explore, 'label': 'Explorar'},
    {'icon': Icons.person, 'label': 'Perfil'},
  ];
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double itemWidth = w / _items.length;
    final double navBarTopOffset = _circleSize / 2;
    final double circleLeft =
        (itemWidth * _selectedIndex) + (itemWidth / 2) - (_circleSize / 2);
    final double circleTop = -navBarTopOffset + (_curveDepth - _gap + 10);
    return SizedBox(
      height: _navBarHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: NavBarClipper(
                circleSize: _circleSize,
                itemWidth: itemWidth,
                selectedIndex: _selectedIndex,
                curveDepth: _curveDepth,
                shoulder: _shoulder,
              ),
              child: Container(
                height: _navBarHeight - navBarTopOffset,
                decoration: BoxDecoration(
                  color: _navBarColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _anim,
            curve: Curves.easeInOut,
            top: circleTop,
            left: circleLeft,
            child: Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                color: _navBarColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Icon(
                    _items[_selectedIndex]['icon'],
                    key: ValueKey(_selectedIndex),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: _navBarHeight - navBarTopOffset,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_items.length, (index) {
                  final bool isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: SizedBox(
                      width: itemWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 0.0 : 1.0,
                            child: SizedBox(
                              height: 28,
                              child: Icon(
                                _items[index]['icon'],
                                color: Colors.white70,
                                size: 24, 
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              _items[index]['label'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarClipper extends CustomClipper<Path> {
  final double circleSize;
  final double itemWidth;
  final int selectedIndex;
  final double curveDepth;
  final double shoulder;
  NavBarClipper({
    required this.circleSize,
    required this.itemWidth,
    required this.selectedIndex,
    required this.curveDepth,
    required this.shoulder,
  });
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double notchCenterX = (itemWidth * selectedIndex) + (itemWidth / 2);
    final double notchRadius = circleSize / 2;
    final double startX = notchCenterX - notchRadius - shoulder;
    final double endX = notchCenterX + notchRadius + shoulder;
    path.moveTo(0, 0);
    path.lineTo(startX, 0);
    path.cubicTo(
      notchCenterX - notchRadius * 0.60,
      0,
      notchCenterX - notchRadius * 0.90,
      curveDepth,
      notchCenterX,
      curveDepth,
    );
    path.cubicTo(
      notchCenterX + notchRadius * 0.90,
      curveDepth,
      notchCenterX + notchRadius * 0.60,
      0,
      endX,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant NavBarClipper oldClipper) {
    return oldClipper.selectedIndex != selectedIndex ||
        oldClipper.circleSize != circleSize ||
        oldClipper.itemWidth != itemWidth ||
        oldClipper.curveDepth != curveDepth ||
        oldClipper.shoulder != shoulder;
  }
}

/// ================== Preview ==================
class CustomNavBarTest extends StatelessWidget {
  const CustomNavBarTest({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: const Stack(
          children: [
            Center(child: Text('Conteúdo de teste')),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomNavBar(),
            ),
          ],
        ),
      ),
    );
  }
}