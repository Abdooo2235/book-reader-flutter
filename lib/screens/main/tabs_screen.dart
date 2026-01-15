import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/screens/main/favourite_screen.dart';
import 'package:book_reader_app/screens/main/home_screen.dart';
import 'package:book_reader_app/screens/main/library_screen.dart';
import 'package:book_reader_app/screens/main/profile_screen.dart';
import 'package:book_reader_app/widgets/submit_book_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    LibraryScreen(),
    FavouriteScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load favorites when tabs screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      bookProvider.loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? scaffoldBackgroundColorDark
        : scaffoldBackgroundColor;
    final navBarColor = isDark ? surfaceColorDark : whiteColor;
    final activeColor = isDark ? primaryColorDark : primaryColor;

    return Consumer<AuthProvider>(
      builder: (context, authConsumer, _) {
        return Scaffold(
          // drawer: CustomDrawer(),
          appBar: AppBar(
            backgroundColor: backgroundColor,
            toolbarHeight: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: isDark
                  ? scaffoldBackgroundColorDark
                  : scaffoldBackgroundColor,

              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          body: IndexedStack(index: currentIndex, children: screens),
          floatingActionButton: currentIndex == 0
              ? Builder(
                  builder: (context) {
                    return FloatingActionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SubmitBookDialog(),
                        );
                      },
                      backgroundColor: activeColor,
                      child: const Icon(Icons.add, color: Colors.white),
                    );
                  },
                )
              : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBarColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 13),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                backgroundColor: navBarColor,
                elevation: 0,
                selectedItemColor: activeColor,
                unselectedItemColor: activeColor.withAlpha(102),
                selectedLabelStyle: labelSmall.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: labelSmall.copyWith(
                  color: activeColor.withAlpha(102),
                ),
                currentIndex: currentIndex,
                onTap: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    label: "Home",
                    icon: Icon(CupertinoIcons.home),
                    activeIcon: Icon(CupertinoIcons.house_fill),
                    backgroundColor: navBarColor,
                  ),
                  BottomNavigationBarItem(
                    label: "Library",
                    icon: Icon(CupertinoIcons.book),
                    activeIcon: Icon(CupertinoIcons.book_fill),
                    backgroundColor: navBarColor,
                  ),
                  BottomNavigationBarItem(
                    label: "Favourites",
                    icon: Icon(CupertinoIcons.heart),
                    activeIcon: Icon(CupertinoIcons.heart_fill),
                    backgroundColor: navBarColor,
                  ),
                  BottomNavigationBarItem(
                    label: "Profile",
                    icon: Icon(CupertinoIcons.person),
                    activeIcon: Icon(CupertinoIcons.person_fill),
                    backgroundColor: navBarColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
