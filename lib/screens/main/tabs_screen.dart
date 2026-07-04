import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/screens/main/favourite_screen.dart';
import 'package:book_reader_app/screens/main/home_screen.dart';
import 'package:book_reader_app/screens/main/library_screen.dart';
import 'package:book_reader_app/screens/main/profile_screen.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/pressable_scale.dart';
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

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      label: 'Home',
      icon: CupertinoIcons.home,
      activeIcon: CupertinoIcons.house_fill,
    ),
    _NavItemData(
      label: 'Library',
      icon: CupertinoIcons.book,
      activeIcon: CupertinoIcons.book_fill,
    ),
    _NavItemData(
      label: 'Favourites',
      icon: CupertinoIcons.heart,
      activeIcon: CupertinoIcons.heart_fill,
    ),
    _NavItemData(
      label: 'Profile',
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
    ),
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
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authConsumer, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: colors.background,
            toolbarHeight: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: colors.background,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          body: IndexedStack(index: currentIndex, children: screens),
          floatingActionButton: currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const SubmitBookDialog(),
                    );
                  },
                  backgroundColor: colors.primary,
                  child: Icon(Icons.add, color: colors.onPrimary),
                )
              : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(borderRadiusXLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingSmall,
                  vertical: spacingSmall + 2,
                ),
                child: Row(
                  children: List.generate(_navItems.length, (index) {
                    return Expanded(
                      child: _NavItem(
                        data: _navItems[index],
                        selected: currentIndex == index,
                        color: colors.primary,
                        inactiveColor: colors.secondaryText,
                        onTap: () => setState(() => currentIndex = index),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// A single animated bottom-nav destination: the active tab grows a tinted pill,
/// swaps to its filled icon, and scales up slightly. Reduced-motion still gets
/// the color/pill change — only the scale is gated.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.color,
    required this.inactiveColor,
    required this.onTap,
  });

  final _NavItemData data;
  final bool selected;
  final Color color;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final activeColor = selected ? color : inactiveColor;

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: animationDurationShort,
        curve: easeOutStrong,
        margin: const EdgeInsets.symmetric(horizontal: spacingSmall / 2),
        padding: const EdgeInsets.symmetric(vertical: spacingSmall),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected && !reduceMotion ? 1.12 : 1.0,
              duration: animationDurationShort,
              curve: easeOutStrong,
              child: Icon(
                selected ? data.activeIcon : data.icon,
                color: activeColor,
                size: 24,
              ),
            ),
            const SizedBox(height: spacingSmall / 2),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: bodySmall.copyWith(
                color: activeColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
