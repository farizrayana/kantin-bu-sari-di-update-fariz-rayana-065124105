import 'package:flutter/material.dart';
import '../main.dart';
import 'menu_detail_page.dart';

/// Halaman Daftar Menu.
/// Widget variatif: AppBar, TextField, PageView (promo), AnimatedContainer
/// (indikator), ChoiceChip, FilterChip, GridView, Card, Hero, Stack,
/// IconButton (favorit), SnackBar.
class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  String _query = '';
  String _category = 'Semua';
  bool _onlyFav = false;
  final _promoController = PageController(viewportFraction: 0.92);
  int _promoIndex = 0;

  static const _promos = [
    ('Diskon 10% pakai kode HEMAT10', '🎉', Color(0xFF8E1B20)),
    ('Potongan Rp 3.000 dengan kode BUSARI', '🎟️', Color(0xFFB8741A)),
    ('Ayam geprek paling laris minggu ini!', '🍗', Color(0xFF2E6B4F)),
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  List<MenuItem> get _filtered => menuList.where((m) {
        final okCat = _category == 'Semua' || m.category == _category;
        final okQuery = m.name.toLowerCase().contains(_query.toLowerCase());
        final okFav = !_onlyFav || cart.isFav(m);
        return okCat && okQuery && okFav;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kantin Bu Sari')),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          final items = _filtered;
          return Column(
            children: [
              // Header sapaan + pencarian
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF5A0508),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mau makan apa hari ini? 😋',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Cari menu...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Carousel promo
              SizedBox(
                height: 92,
                child: PageView.builder(
                  controller: _promoController,
                  itemCount: _promos.length,
                  onPageChanged: (i) => setState(() => _promoIndex = i),
                  itemBuilder: (_, i) {
                    final p = _promos[i];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(6, 10, 6, 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: p.$3,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(p.$1,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                          Text(p.$2, style: const TextStyle(fontSize: 38)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Indikator halaman promo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _promos.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _promoIndex == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _promoIndex == i
                          ? const Color(0xFF5A0508)
                          : Colors.black26,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              // Filter kategori + favorit
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == categories.length) {
                      return FilterChip(
                        label: const Text('❤ Favorit'),
                        selected: _onlyFav,
                        onSelected: (v) => setState(() => _onlyFav = v),
                      );
                    }
                    final selected = _category == categories[i];
                    return ChoiceChip(
                      label: Text(categories[i]),
                      selected: selected,
                      selectedColor: const Color(0xFF5A0508),
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87),
                      onSelected: (_) =>
                          setState(() => _category = categories[i]),
                    );
                  },
                ),
              ),
              // Grid menu
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Menu tidak ditemukan 😢'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) => _MenuCard(item: items[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuDetailPage(item: item)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: item.color,
                    alignment: Alignment.center,
                    child: Hero(
                      tag: 'emoji-${item.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(item.emoji,
                            style: const TextStyle(fontSize: 54)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white70),
                      icon: Icon(
                        cart.isFav(item)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => cart.toggleFav(item),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(' ${item.rating}',
                        style: const TextStyle(fontSize: 12)),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rupiah(item.price),
                          style: const TextStyle(
                              color: Color(0xFF5A0508),
                              fontWeight: FontWeight.w600)),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFF5A0508)),
                        onPressed: () {
                          cart.add(item);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text('${item.name} ditambahkan'),
                              duration: const Duration(seconds: 1),
                            ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}