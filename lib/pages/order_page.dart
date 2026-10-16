import 'package:flutter/material.dart';
import '../main.dart';

/// Halaman Pesanan: dua tab (Keranjang & Riwayat).
/// Widget variatif: TabBar, TabBarView, ListView, Dismissible, Card, ListTile,
/// TextField (voucher), SegmentedButton, Divider, AlertDialog,
/// LinearProgressIndicator, ExpansionTile, Chip.
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart), text: 'Keranjang'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Riwayat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_CartTab(), _HistoryTab()],
        ),
      ),
    );
  }
}

// ======================= TAB KERANJANG =======================

class _CartTab extends StatefulWidget {
  const _CartTab();

  @override
  State<_CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<_CartTab> {
  String _payment = 'Tunai';
  final _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _applyVoucher() {
    final ok = cart.applyVoucher(_voucherController.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(ok ? 'Voucher berhasil dipakai 🎉' : 'Kode voucher tidak valid'),
    ));
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: Text(
            'Total ${rupiah(cart.grandTotal)} dibayar dengan $_payment. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              cart.checkout(_payment);
              _voucherController.clear();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Pesanan berhasil! Silakan ambil di kantin 🎉')));
            },
            child: const Text('Pesan'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontSize: bold ? 20 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🛒', style: TextStyle(fontSize: 64)),
                SizedBox(height: 8),
                Text('Keranjang masih kosong'),
              ],
            ),
          );
        }
        final lines = cart.lines;
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lines.length,
                itemBuilder: (_, i) {
                  final l = lines[i];
                  return Dismissible(
                    key: ValueKey(l.item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => cart.remove(l.item),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: l.item.color,
                          child: Text(l.item.emoji),
                        ),
                        title: Text(l.item.name),
                        subtitle: Text(
                            '${rupiah(l.item.price)}${l.note.isEmpty ? '' : '\n${l.note}'}'),
                        isThreeLine: l.note.isNotEmpty,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cart.decrease(l.item),
                            ),
                            Text('${l.qty}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => cart.add(l.item),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Kode voucher',
                            prefixIcon: const Icon(Icons.local_offer_outlined),
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: _applyVoucher, child: const Text('Pakai')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                          value: 'Tunai',
                          label: Text('Tunai'),
                          icon: Icon(Icons.payments)),
                      ButtonSegment(
                          value: 'QRIS',
                          label: Text('QRIS'),
                          icon: Icon(Icons.qr_code)),
                      ButtonSegment(
                          value: 'Saldo',
                          label: Text('Saldo'),
                          icon: Icon(Icons.account_balance_wallet)),
                    ],
                    selected: {_payment},
                    onSelectionChanged: (s) =>
                        setState(() => _payment = s.first),
                  ),
                  const Divider(height: 24),
                  _row('Subtotal', rupiah(cart.total)),
                  if (cart.discount > 0)
                    _row('Diskon (${cart.voucher})',
                        '- ${rupiah(cart.discount)}',
                        color: Colors.green[700]),
                  const SizedBox(height: 6),
                  _row('Total', rupiah(cart.grandTotal),
                      bold: true, color: const Color(0xFF5A0508)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _checkout,
                        child: const Text('Pesan Sekarang')),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ======================= TAB RIWAYAT =======================

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  static const _targetMember = 10;

  String _fmt(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _stat(IconData icon, String value, String label) => Column(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      );

  Widget _summary() {
    final n = cart.history.length;
    final spent = cart.history.fold<int>(0, (s, o) => s + o.total);
    final progress = n >= _targetMember ? 1.0 : n / _targetMember;
    return Card(
      color: const Color(0xFF5A0508),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat(Icons.receipt_long, '$n', 'Pesanan'),
                _stat(Icons.payments, rupiah(spent), 'Total belanja'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              n >= _targetMember
                  ? 'Selamat, kamu member Gold! 🏅'
                  : 'Menuju member Gold ($n/$_targetMember pesanan)',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🧾', style: TextStyle(fontSize: 64)),
                SizedBox(height: 8),
                Text('Belum ada pesanan'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cart.history.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) return _summary();
            final o = cart.history[i - 1];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                shape: const Border(),
                leading:
                    const Icon(Icons.receipt_long, color: Color(0xFF5A0508)),
                title: Text('Pesanan #${cart.history.length - (i - 1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_fmt(o.time)),
                trailing: Chip(label: Text(rupiah(o.total))),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  for (final l in o.lines)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Text(l.item.emoji,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(l.item.name),
                      trailing: Text('${l.qty} × ${rupiah(l.item.price)}'),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Bayar: ${o.payment}',
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}