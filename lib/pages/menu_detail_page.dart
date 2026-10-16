import 'package:flutter/material.dart';
import '../main.dart';

/// Halaman Detail Menu.
/// Widget variatif: Hero, Chip, ChoiceChip + Wrap (level pedas),
/// SegmentedButton (suhu), SwitchListTile (bungkus), TextField (catatan),
/// IconButton.filledTonal (stepper), ElevatedButton, Divider, SnackBar.
class MenuDetailPage extends StatefulWidget {
  final MenuItem item;
  const MenuDetailPage({super.key, required this.item});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  int _qty = 1;
  late String _variant;
  bool _takeAway = false;
  final _noteController = TextEditingController();

  static const _pedasLevels = ['Tidak pedas', 'Sedang', 'Pedas', 'Extra pedas'];

  @override
  void initState() {
    super.initState();
    _variant = switch (widget.item.category) {
      'Makanan' => 'Sedang',
      'Minuman' => 'Dingin',
      _ => '',
    };
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final total = item.price * _qty;
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          ListenableBuilder(
            listenable: cart,
            builder: (_, __) => IconButton(
              icon: Icon(
                  cart.isFav(item) ? Icons.favorite : Icons.favorite_border),
              onPressed: () => cart.toggleFav(item),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 220,
            color: item.color,
            alignment: Alignment.center,
            child: Hero(
              tag: 'emoji-${item.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(item.emoji, style: const TextStyle(fontSize: 110)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    Chip(
                      avatar:
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                      label: Text('${item.rating}'),
                    ),
                  ],
                ),
                Text(rupiah(item.price),
                    style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF5A0508),
                        fontWeight: FontWeight.w600)),
                const Divider(height: 28),
                const Text('Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(item.description),
                const SizedBox(height: 16),
                if (item.category == 'Makanan') ...[
                  const Text('Level pedas 🌶️',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final lv in _pedasLevels)
                        ChoiceChip(
                          label: Text(lv),
                          selected: _variant == lv,
                          selectedColor: const Color(0xFFE8C9CB),
                          onSelected: (_) => setState(() => _variant = lv),
                        ),
                    ],
                  ),
                ],
                if (item.category == 'Minuman') ...[
                  const Text('Suhu',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                          value: 'Dingin',
                          label: Text('Dingin'),
                          icon: Icon(Icons.ac_unit)),
                      ButtonSegment(
                          value: 'Hangat',
                          label: Text('Hangat'),
                          icon: Icon(Icons.local_fire_department)),
                    ],
                    selected: {_variant},
                    onSelectionChanged: (s) =>
                        setState(() => _variant = s.first),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bungkus (take away) 🛍️'),
                  value: _takeAway,
                  activeColor: const Color(0xFF5A0508),
                  onChanged: (v) => setState(() => _takeAway = v),
                ),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Catatan untuk penjual',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('$_qty',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => setState(() => _qty++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: Text('Tambah ke keranjang • ${rupiah(total)}'),
            onPressed: () {
              final parts = [
                if (_variant.isNotEmpty) _variant,
                if (_takeAway) 'Dibungkus',
                if (_noteController.text.trim().isNotEmpty)
                  _noteController.text.trim(),
              ];
              cart.add(item, qty: _qty, note: parts.join(' • '));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$_qty × ${item.name} masuk keranjang'),
              ));
            },
          ),
        ),
      ),
    );
  }
}