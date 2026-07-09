import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../models/room_model.dart';
import '../widgets/room_card.dart';
import '../widgets/shimmer_loader.dart';
import 'room_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String guestId;
  final String guestName;

  const HomeScreen({super.key, required this.guestId, required this.guestName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _apiService = ApiService();
  late List<RoomModel> _allRooms;
  List<RoomModel> _filteredRooms = [];
  bool _isLoading = true;
  String? _error;
  int _selectedFilter = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<String> _filters = ['All', 'Single', 'Double', 'Suite'];

  @override
  void initState() {
    super.initState();
    _allRooms = [];
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadRooms();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _allRooms = await _apiService.getAllRooms();
      _filterRooms(0);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterRooms(int index) {
    setState(() {
      _selectedFilter = index;
      if (index == 0) {
        _filteredRooms = List.from(_allRooms);
      } else {
        _filteredRooms = _allRooms.where((r) =>
          r.roomType.toLowerCase() == _filters[index].toLowerCase()
        ).toList();
      }
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppConstants.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadRooms,
            color: AppConstants.gold,
            backgroundColor: AppConstants.cardDark,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildFilterChips()),
                _isLoading
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: ShimmerLoader(),
                        ),
                      )
                    : _error != null
                        ? SliverToBoxAdapter(child: _buildError())
                        : _filteredRooms.isEmpty
                            ? SliverToBoxAdapter(child: _buildEmpty())
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final room = _filteredRooms[index];
                                    return AnimatedBuilder(
                                      animation: _fadeAnim,
                                      builder: (context, child) {
                                        final delay = (index * 100).clamp(0, 500);
                                        final itemAnim = CurvedAnimation(
                                          parent: _fadeController,
                                          curve: Interval(
                                            delay / 2000,
                                            (delay + 400) / 2000,
                                            curve: Curves.easeOut,
                                          ),
                                        );
                                        return AnimatedBuilder(
                                          animation: itemAnim,
                                          builder: (context, child) {
                                            return Opacity(
                                              opacity: itemAnim.value,
                                              child: Transform.translate(
                                                offset: Offset(0, 30 * (1 - itemAnim.value)),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: RoomCard(
                                            room: room,
                                            onTap: () => _openRoomDetail(room),
                                          ),
                                        );
                                      },
                                      child: const SizedBox.shrink(),
                                    );
                                  },
                                  childCount: _filteredRooms.length,
                                ),
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) greeting = 'Good Morning';
    else if (hour < 17) greeting = 'Good Afternoon';
    else greeting = 'Good Evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppConstants.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.guestName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppConstants.goldGradient,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppConstants.cardDark,
                  child: Text(
                    widget.guestName.isNotEmpty
                        ? widget.guestName[0].toUpperCase()
                        : 'G',
                    style: GoogleFonts.playfairDisplay(
                      color: AppConstants.gold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Find your perfect stay',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          Color chipColor;
          switch (index) {
            case 1: chipColor = AppConstants.singleColor; break;
            case 2: chipColor = AppConstants.doubleColor; break;
            case 3: chipColor = AppConstants.suiteColor; break;
            default: chipColor = AppConstants.gold;
          }
          return GestureDetector(
            onTap: () => _filterRooms(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          chipColor,
                          chipColor.withAlpha(180),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withAlpha(12),
                border: Border.all(
                  color: isSelected
                      ? chipColor
                      : Colors.white.withAlpha(20),
                  width: isSelected ? 0 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : AppConstants.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.white.withAlpha(50)),
          const SizedBox(height: 16),
          Text(
            'Could not load rooms',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: GoogleFonts.inter(fontSize: 13, color: AppConstants.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loadRooms,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppConstants.goldGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.hotel, size: 64, color: Colors.white.withAlpha(50)),
          const SizedBox(height: 16),
          Text(
            'No rooms found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              color: AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _openRoomDetail(RoomModel room) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => RoomDetailScreen(room: room, guestId: widget.guestId),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
