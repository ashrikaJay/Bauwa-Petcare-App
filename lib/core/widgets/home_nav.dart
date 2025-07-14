//Original nav bar
/*
import 'package:flutter/material.dart';
import 'package:bauwa/view/dashboard/dashboard.dart';
import 'package:bauwa/view/pets/pets_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const DashboardPage(),
    const PetsPage(),
    const Center(child: Text("Appointments Page")), // Placeholder

    const Center(child: Text("Reminders Page")), // Placeholder
    const Center(child: Text("Settings Page")), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Pets"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Reminders"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}*/

//current
import 'package:bauwa/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:bauwa/view/dashboard/dashboard.dart';
import 'package:bauwa/view/pets/pets_page.dart';
import 'package:bauwa/view/settings/settings_page.dart';
import 'package:bauwa/core/widgets/custom_nav_painter.dart';
import 'package:bauwa/controllers/auth_controller.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _nickname = '';
  String _email = '';
  String? _profilePicUrl;

  int _selectedIndex = 0;

  late final List<Widget> _pages;

  final List<GlobalKey> iconKeys = List.generate(5, (_) => GlobalKey());
  List<Offset> iconPositions = List.filled(5, Offset.zero);

  final GlobalKey<DentAnimationWidgetState> childGlobalKey =
  GlobalKey<DentAnimationWidgetState>();

  late AnimationController _appBarController;

  /*VoidCallback _buildDrawerOpener(BuildContext context) {
    return () {
      final scaffold = Scaffold.maybeOf(context);
      scaffold?.openDrawer();
    };
  }*/

  void _onNavItemTap(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    childGlobalKey.currentState?.onParentClick(index);
    _appBarController.forward(from: 0);

    // Recalculate icon positions in case layout has shifted
    Future.delayed(const Duration(milliseconds: 100), _getIconPositions);
  }

  void _getIconPositions() {
    final updatedPositions = <Offset>[];

    for (var key in iconKeys) {
      final context = key.currentContext;
      if (context == null) {
        updatedPositions.add(Offset.zero);
        continue;
      }

      final renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      updatedPositions.add(position + Offset(size.width / 2, size.height / 2));

    }

    setState(() {
      iconPositions = updatedPositions;
    });

  }

  @override
  void initState() {
    super.initState();

    _appBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _loadUserData();

    _pages = [
      Builder(
        builder: (context) {
          return DashboardPage(
            onOpenDrawer: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      //PetsPage(onOpenDrawer: _buildDrawerOpener(context)),
      Builder(
        builder: (context) {
          return PetsPage(
            onOpenDrawer: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),

      const Center(child: Text("Appointments Page")),
      const Center(child: Text("Reminders Page")),
      const SettingsPage(),
    ];

    // Delay icon position collection to ensure render completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), _getIconPositions);
    });
  }

  Future<void> _loadUserData() async {
    final userData = await AuthController.instance.fetchUserData();
    if (userData != null) {
      setState(() {
        _nickname = userData['nickname'] ?? '';
        _email = userData['email'] ?? '';
        _profilePicUrl = userData['photoUrl'];
      });
    }
  }

  void _logout() async {
    await AuthController.instance.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login'); // or your login screen route
    }
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.pets;
      case 2:
        return Icons.calendar_today;
      case 3:
        return Icons.notifications;
      case 4:
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _appBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      //backgroundColor: Color(0xE82C0D05),backgroundColor: Color(0xFF3F8E81),
      backgroundColor: Color(0xFFD99C2B),
      drawer: CustomDrawer(
        nickname: _nickname,
        email: _email,
        profilePicUrl: _profilePicUrl,
        onLogout: _logout,
        onNavigateToSettings: () {
          setState(() {
            _selectedIndex = 4; // Settings page index
          });
        },
      ),

      body: Stack(
        children: [
          // Page content
          Column(
            children: [
              /*Expanded(child: _pages[_selectedIndex]),*/ //flicker issue

              ///Resolved flicker issue
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),

              SizedBox(height: screenHeight * 0.1),
            ],
          ),

          // Animated Bottom Nav Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: screenHeight * 0.25,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  RepaintBoundary(
                    child: DentAnimationWidget(
                      key: childGlobalKey,
                      iconPositions: iconPositions,
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_pages.length, (index) {
                        return GestureDetector(
                          onTap: () => _onNavItemTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            transform: Matrix4.translationValues(
                              0,
                              _selectedIndex == index ? -15 : 0,
                              0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Icon(
                                _getIcon(index),
                                key: iconKeys[index],
                                size: 28,
                                color: _selectedIndex == index
                                    //? const Color(0xFF429EBD)
                                    //? const Color(0xFF9FE7F5)
                                    ? const Color(0xFFD9D1C7)
                                    //: Colors.white,
                                    : Color(0xFF632024),

                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



