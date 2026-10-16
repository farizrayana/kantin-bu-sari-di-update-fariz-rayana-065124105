import 'package:flutter/material.dart';
import 'pages/menu_list_page.dart';
import 'pages/order_page.dart';

void main() => runApp(const KantinBuSariApp());

// ======================= MODEL & DATA =======================

class MenuItem {
  final int id;
  final String name;
  final String category; // Makanan / Minuman / Snack
  final int price;
  final String emoji;
  final String description;
  final double rating;
  final Color color;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.emoji,
    required this.description,
    required this.rating,
    required this.color,
  });
}

const List<String> categories = ['Semua', 'Makanan', 'Minuman', 'Snack'];

const List<MenuItem> menuList = [
  MenuItem(
    id: 1, name: 'Nasi Goreng Spesial', category: 'Makanan', price: 15000,
    emoji: '🍛', rating: 4.8, color: Color(0xFFFFE0B2),
    description: 'Nasi goreng bumbu rempah dengan telur mata sapi, ayam suwir, dan kerupuk.',
  ),
  MenuItem(
    id: 2, name: 'Mie Ayam Bakso', category: 'Makanan', price: 14000,
    emoji: '🍜', rating: 4.7, color: Color(0xFFFFF3C4),
    description: 'Mie ayam kuah gurih dengan topping bakso sapi dan pangsit goreng.',
  ),
  MenuItem(
    id: 3, name: 'Ayam Geprek', category: 'Makanan', price: 17000,
    emoji: '🍗', rating: 4.9, color: Color(0xFFFFCDD2),
    description: 'Ayam crispy digeprek dengan sambal bawang pedas, disajikan dengan nasi hangat.',
  ),
  MenuItem(
    id: 4, name: 'Es Teh Manis', category: 'Minuman', price: 4000,
    emoji: '🧋', rating: 4.5, color: Color(0xFFD7CCC8),
    description: 'Teh seduh segar dengan gula asli dan es batu.',
  ),
  MenuItem(
    id: 5, name: 'Es Jeruk', category: 'Minuman', price: 6000,
    emoji: '🍊', rating: 4.6, color: Color(0xFFFFE082),
    description: 'Perasan jeruk peras segar, manis asam yang pas.',
  ),
  MenuItem(
    id: 6, name: 'Kopi Susu Kantin', category: 'Minuman', price: 8000,
    emoji: '☕', rating: 4.7, color: Color(0xFFBCAAA4),
    description: 'Kopi susu gula aren khas kantin, pilihan teman begadang tugas.',
  ),
  MenuItem(
    id: 7, name: 'Pisang Goreng', category: 'Snack', price: 5000,
    emoji: '🍌', rating: 4.4, color: Color(0xFFFFF59D),
    description: 'Pisang goreng tepung renyah, isi 3 potong.',
  ),
  MenuItem(
    id: 8, name: 'Risoles Mayo', category: 'Snack', price: 6000,
    emoji: '🥟', rating: 4.6, color: Color(0xFFFFCCBC),
    description: 'Risoles isi sayur, telur, dan saus mayo creamy.',
  ),
];

String rupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

class CartLine {
  final MenuItem item;
  int qty;
  String note;
  CartLine(this.item, this.qty, [this.note = '']);
}

class OrderRecord {
  final DateTime time;
  final List<CartLine> lines;
  final int total;
  final String payment;
  OrderRecord(this.time, this.lines, this.total, this.payment);
}

/// State keranjang global (tanpa package tambahan).
class CartModel extends ChangeNotifier {
  final Map<int, CartLine> _lines = {};
  final List<OrderRecord> history = [];
  final Set<int> favorites = {};
  String? voucher;

  bool isFav(MenuItem i) => favorites.contains(i.id);

  void toggleFav(MenuItem i) {
    if (!favorites.remove(i.id)) favorites.add(i.id);
    notifyListeners();
  }

  /// Voucher valid: HEMAT10 (diskon 10%) dan BUSARI (potongan Rp 3.000).
  bool applyVoucher(String code) {
    final c = code.trim().toUpperCase();
    if (c == 'HEMAT10' || c == 'BUSARI') {
      voucher = c;
      notifyListeners();
      return true;
    }
    return false;
  }

  int get discount {
    if (voucher == 'HEMAT10') return (total * 0.1).round();
    if (voucher == 'BUSARI') return total < 3000 ? total : 3000;
    return 0;
  }

  int get grandTotal => total - discount;

  List<CartLine> get lines => _lines.values.toList();
  int get count => _lines.values.fold(0, (s, l) => s + l.qty);
  int get total => _lines.values.fold(0, (s, l) => s + l.qty * l.item.price);
  bool get isEmpty => _lines.isEmpty;

  void add(MenuItem item, {int qty = 1, String note = ''}) {
    final existing = _lines[item.id];
    if (existing != null) {
      existing.qty += qty;
      if (note.isNotEmpty) existing.note = note;
    } else {
      _lines[item.id] = CartLine(item, qty, note);
    }
    notifyListeners();
  }

  void decrease(MenuItem item) {
    final l = _lines[item.id];
    if (l == null) return;
    l.qty--;
    if (l.qty <= 0) _lines.remove(item.id);
    notifyListeners();
  }

  void remove(MenuItem item) {
    _lines.remove(item.id);
    notifyListeners();
  }

  void checkout(String payment) {
    if (_lines.isEmpty) return;
    history.insert(
      0,
      OrderRecord(DateTime.now(),
          _lines.values.map((l) => CartLine(l.item, l.qty, l.note)).toList(),
          grandTotal, payment),
    );
    _lines.clear();
    voucher = null;
    notifyListeners();
  }
}

final CartModel cart = CartModel();

// ======================= APP =======================

/// Widget root aplikasi (StatelessWidget: tidak punya state berubah).
class KantinBuSariApp extends StatelessWidget {
  const KantinBuSariApp({super.key});

  static const Color maroon = Color(0xFF5A0508);
  static const Color cream = Color(0xFFFAF8E6);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kantin Bu Sari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: maroon,
          primary: maroon,
          surface: cream,
        ),
        scaffoldBackgroundColor: cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

/// StatefulWidget: index tab yang aktif berubah -> butuh state.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [MenuListPage(), OrderPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: cart,
        builder: (context, _) => NavigationBar(
          selectedIndex: _index,
          indicatorColor: const Color(0xFFE8C9CB),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.restaurant_menu), label: 'Menu'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cart.count > 0,
                label: Text('${cart.count}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              label: 'Pesanan',
            ),
          ],
        ),
      ),
    );
  }
}