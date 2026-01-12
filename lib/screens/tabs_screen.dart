import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/helper_functions.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/screens/main/cart_screen.dart';
import 'package:book_reader_app/screens/main/favourite_screen.dart';
import 'package:book_reader_app/screens/main/home_screen.dart';
import 'package:book_reader_app/screens/main/library_screen.dart';
import 'package:book_reader_app/screens/main/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
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
    CartScreen(),
    FavouriteScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authConsumer, _) {
        return Scaffold(
          // drawer: CustomDrawer(),
          appBar: AppBar(
            backgroundColor: scaffoldBackgroundColor,
            centerTitle: true,
            // title: SvgPicture.asset(
            //   "assets/images/book_logo.svg",
            //   width: getSize(context).width * 0.3,
            //   fit: BoxFit.cover,
            // ),
          ),
          body: IndexedStack(index: currentIndex, children: screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
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
                backgroundColor: whiteColor,
                elevation: 0,
                selectedItemColor: primaryColor,
                unselectedItemColor: primaryColor.withAlpha(102),
                selectedLabelStyle: labelSmall.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: labelSmall.copyWith(
                  color: primaryColor.withAlpha(102),
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
                    backgroundColor: whiteColor,
                  ),
                  BottomNavigationBarItem(
                    label: "Library",
                    icon: Icon(CupertinoIcons.book),
                    activeIcon: Icon(CupertinoIcons.book_fill),
                    backgroundColor: whiteColor,
                  ),
                  BottomNavigationBarItem(
                    label: "Cart",
                    icon: Icon(CupertinoIcons.shopping_cart),
                    activeIcon: Icon(CupertinoIcons.cart_fill),
                    backgroundColor: whiteColor,
                  ),
                  BottomNavigationBarItem(
                    label: "Favourites",
                    icon: Icon(CupertinoIcons.heart),
                    activeIcon: Icon(CupertinoIcons.heart_fill),
                    backgroundColor: whiteColor,
                  ),
                  BottomNavigationBarItem(
                    label: "Profile",
                    icon: Icon(CupertinoIcons.person),
                    activeIcon: Icon(CupertinoIcons.person_fill),
                    backgroundColor: whiteColor,
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
