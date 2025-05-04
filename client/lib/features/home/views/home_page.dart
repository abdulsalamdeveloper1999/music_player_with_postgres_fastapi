import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/views/songs_page.dart';
import 'package:client/features/home/views/widgets/music_player.dart';
import 'package:client/features/home/views/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  bool isPlayerExpanded = false;
  double playerHeight = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final pages = [
    const SongsPage(),
    const Center(child: Text('Library', style: TextStyle(color: Colors.white))),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMusicPlayer() {
    setState(() {
      isPlayerExpanded = !isPlayerExpanded;
    });

    if (isPlayerExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      bottomNavigationBar: isPlayerExpanded
          ? null
          : BottomNavigationBar(
              backgroundColor: Pallete.backgroundColor,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              currentIndex: selectedIndex,
              selectedItemColor: Pallete.whiteColor,
              unselectedItemColor: Pallete.inactiveBottomBarItemColor,
              items: [
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/images/${selectedIndex == 0 ? 'home_filled.png' : 'home_unfilled.png'}',
                    color: selectedIndex == 0
                        ? Pallete.whiteColor
                        : Pallete.inactiveBottomBarItemColor,
                    height: 24,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/images/library.png',
                    color: selectedIndex == 1
                        ? Pallete.whiteColor
                        : Pallete.inactiveBottomBarItemColor,
                    height: 24,
                  ),
                  label: 'Library',
                )
              ],
            ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Main content
          Positioned.fill(
            bottom: isPlayerExpanded
                ? 0
                : 70, // Adjust based on the mini player height
            child: pages[selectedIndex],
          ),

          // Animated Music Player (full screen when expanded)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double playerExpandedHeight = screenHeight;
              final double playerCollapsedHeight = 70.0;
              final currentHeight = isPlayerExpanded
                  ? playerCollapsedHeight +
                      (playerExpandedHeight - playerCollapsedHeight) *
                          _animation.value
                  : playerCollapsedHeight;

              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: currentHeight,
                child: GestureDetector(
                  onTap: isPlayerExpanded ? null : _toggleMusicPlayer,
                  onVerticalDragEnd: (details) {
                    // Detect swipe direction
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! > 0 && isPlayerExpanded) {
                        // Swipe down
                        _toggleMusicPlayer();
                      } else if (details.primaryVelocity! < 0 &&
                          !isPlayerExpanded) {
                        // Swipe up
                        _toggleMusicPlayer();
                      }
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isPlayerExpanded && _animation.value > 0.5
                        ? const MusicPlayer()
                        : MusicSlab(
                            onExpandTap: _toggleMusicPlayer,
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
