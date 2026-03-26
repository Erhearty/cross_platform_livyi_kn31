import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3A6B)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TravelHomePage(),
    );
  }
}

// ── Модель даних ─────────────────────────────────────────────────────────────

class Deal {
  final String city;
  final String country;
  final int price;
  const Deal({required this.city, required this.country, required this.price});
}

class Destination {
  final String city;
  final String country;
  const Destination({required this.city, required this.country});
}

// ── Головний екран ───────────────────────────────────────────────────────────

class TravelHomePage extends StatefulWidget {
  const TravelHomePage({super.key});

  @override
  State<TravelHomePage> createState() => _TravelHomePageState();
}

class _TravelHomePageState extends State<TravelHomePage> {
  int _selectedIndex = 0;

  static const Color _navyBlue = Color(0xFF1A3A6B);
  static const Color _accentBlue = Color(0xFF2B5CE6);
  static const Color _bgGray = Color(0xFFF3F4F8);

  final List<Deal> _deals = const [
    Deal(city: 'El Cairo', country: 'Egypt', price: 260),
    Deal(city: 'London', country: 'England', price: 330),
  ];

  final List<Destination> _destinations = const [
    Destination(city: 'Cancun', country: 'Mexico'),
    Destination(city: 'Santorini', country: 'Greece'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      body: SafeArea(
        child: Column(
          children: [
            // ── Синя шапка ────────────────────────────────────────────────
            _buildHeader(),

            // ── Прокручуваний вміст ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Best Deals'),
                    const SizedBox(height: 12),
                    _buildDealsRow(),
                    const SizedBox(height: 24),
                    _sectionTitle('Popular Destinations'),
                    const SizedBox(height: 12),
                    _buildDestinationsGrid(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Нижня навігація ───────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Шапка ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: _navyBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.zero,
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where do you want to travel?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          // Рядок пошуку
          Row(
            children: [
              // Іконка сітки
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.grid_view_outlined,
                    color: _accentBlue,
                    size: 22),
              ),
              const SizedBox(width: 10),

              // Поле вибору напрямку
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B52A0),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Select Destination',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Кнопка пошуку
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search,
                    color: _accentBlue,
                    size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Заголовок секції ──────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // ── Картки Best Deals ──────────────────────────────────────────────────────

  Widget _buildDealsRow() {
    return Row(
      children: _deals.map((deal) {
        final isLast = _deals.last == deal;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: _DealCard(deal: deal),
          ),
        );
      }).toList(),
    );
  }

  // ── Сітка Popular Destinations ────────────────────────────────────────────

  Widget _buildDestinationsGrid() {
    return Row(
      children: _destinations.map((dest) {
        final isLast = _destinations.last == dest;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: _DestinationCard(destination: dest),
          ),
        );
      }).toList(),
    );
  }

  // ── Нижня навігація ───────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      Icons.home_rounded,
      Icons.explore_outlined,
      Icons.favorite_border_rounded,
      Icons.settings_outlined,
    ];

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8EE), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = i == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 56,
              child: Icon(
                items[i],
                size: 26,
                color: isSelected
                    ? const Color(0xFF1A3A6B)
                    : const Color(0xFFAAAAAA),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Картка Deal ──────────────────────────────────────────────────────────────

class _DealCard extends StatelessWidget {
  final Deal deal;
  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deal.city,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            deal.country,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9A9AAF),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'More',
                style: TextStyle(
                  fontSize: 13,
                  color: _TravelHomePageState._accentBlue,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _TravelHomePageState._navyBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${deal.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Картка Destination ───────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  const _DestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder зображення
          Container(
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFEAEDF5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Center(
              child: Icon(
                Icons.landscape_rounded,
                size: 48,
                color: Color(0xFFB0B8CC),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.city,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  destination.country,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9A9AAF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}