import 'package:flutter/material.dart';

void main() {
  runApp(const BukuWarungApp());
}

/* ================= APP ROOT ================= */
class BukuWarungApp extends StatelessWidget {
  const BukuWarungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Warung',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const MainPage(),
    );
  }
}

/* ================= MODEL ================= */
class Customer {
  String name;
  String phone;
  Customer(this.name, this.phone);
}

class Product {
  String name;
  int price;
  int stock;
  Product(this.name, this.price, this.stock);
}

class TransactionModel {
  Customer customer;
  Product product;
  int qty;
  int total;
  TransactionModel(this.customer, this.product, this.qty)
      : total = qty * product.price;
}

/* ================= MAIN PAGE ================= */
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  final customers = <Customer>[];
  final products = <Product>[];
  final transactions = <TransactionModel>[];

  int get totalSales =>
      transactions.fold(0, (sum, t) => sum + t.total);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        total: totalSales,
        customer: customers.length,
        product: products.length,
      ),
      CustomerPage(customers),
      ProductPage(products, () => setState(() {})),
      TransactionPage(customers, products, transactions, () {
        setState(() {});
      }),
      ReportPage(customers.length, products.length, totalSales),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Buku Warung')),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Customer'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Laporan'),
        ],
      ),
    );
  }
}

/* ================= DASHBOARD ================= */
class DashboardPage extends StatelessWidget {
  final int total, customer, product;
  const DashboardPage(
      {super.key, required this.total, required this.customer, required this.product});

  Widget box(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            box('Total Penjualan', 'Rp $total', Icons.wallet, Colors.teal),
            box('Customer', '$customer', Icons.people, Colors.blue),
            box('Produk', '$product', Icons.inventory, Colors.orange),
          ],
        ),
      );
}

/* ================= CUSTOMER ================= */
class CustomerPage extends StatefulWidget {
  final List<Customer> data;
  const CustomerPage(this.data, {super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {

  void addCustomer() {
    final name = TextEditingController();
    final phone = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'No HP'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.isEmpty) return;
              setState(() {
                widget.data.add(Customer(name.text, phone.text));
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void deleteCustomer(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Customer'),
        content: const Text('Yakin ingin menghapus customer ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                widget.data.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addCustomer,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          final c = widget.data[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(c.name),
              subtitle: Text(c.phone),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteCustomer(index),
              ),
            ),
          );
        },
      ),
    );
  }
}


/* ================= PRODUCT ================= */
class ProductPage extends StatefulWidget {
  final List<Product> products;
  final VoidCallback refresh;

  const ProductPage(this.products, this.refresh, {super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  void addProduct() {
    final name = TextEditingController();
    final price = TextEditingController();
    final stock = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
            TextField(
              controller: stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Simpan'),
            onPressed: () {
              if (name.text.isEmpty) return;
              widget.products.add(
                Product(
                  name.text,
                  int.parse(price.text),
                  int.parse(stock.text),
                ),
              );
              widget.refresh();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void editStock(Product p) {
    final ctrl = TextEditingController(text: p.stock.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Stok'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stok Baru'),
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Simpan'),
            onPressed: () {
              p.stock = int.parse(ctrl.text);
              widget.refresh();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void deleteProduct(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
            'Yakin ingin menghapus produk "${p.name}"?\n\nProduk yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () {
              widget.products.remove(p);
              widget.refresh();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addProduct,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final p = widget.products[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(p.name),
              subtitle: Text(
                  'Rp ${p.price} • Stok ${p.stock}'),
              leading: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => editStock(p),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteProduct(p),
              ),
            ),
          );
        },
      ),
    );
  }
}


/* ================= TRANSAKSI ================= */
class TransactionPage extends StatelessWidget {
  final List<Customer> customers;
  final List<Product> products;
  final List<TransactionModel> transactions;
  final VoidCallback refresh;

  const TransactionPage(
      this.customers, this.products, this.transactions, this.refresh,
      {super.key});

  void addTransaction(BuildContext context) {
    Customer? c;
    Product? p;
    final qtyCtrl = TextEditingController();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Transaksi Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Customer>(
                    hint: const Text('Customer'),
                    items: customers
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e.name)))
                        .toList(),
                    onChanged: (v) => c = v,
                  ),
                  DropdownButtonFormField<Product>(
                    hint: const Text('Produk'),
                    items: products
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e.name)))
                        .toList(),
                    onChanged: (v) => p = v,
                  ),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah'),
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                    onPressed: () {
                      final qty = int.parse(qtyCtrl.text);
                      if (p!.stock < qty) return;
                      p!.stock -= qty;
                      transactions.add(TransactionModel(c!, p!, qty));
                      refresh();
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan'))
              ],
            ));
  }

  void deleteTransaction(BuildContext context, int i) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Hapus Transaksi'),
              content: const Text('Yakin ingin menghapus transaksi ini?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                    onPressed: () {
                      transactions[i].product.stock += transactions[i].qty;
                      transactions.removeAt(i);
                      refresh();
                      Navigator.pop(context);
                    },
                    child: const Text('Hapus'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () => addTransaction(context),
            child: const Icon(Icons.add)),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: transactions.length,
          itemBuilder: (_, i) => Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text('${transactions[i].product.name} x${transactions[i].qty}'),
              subtitle: Text(
                  '${transactions[i].customer.name} • Rp ${transactions[i].total}'),
              trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteTransaction(context, i)),
            ),
          ),
        ),
      );
}

/* ================= REPORT ================= */
class ReportPage extends StatelessWidget {
  final int customer, product, total;
  const ReportPage(this.customer, this.product, this.total, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(child: ListTile(title: const Text('Customer'), trailing: Text('$customer'))),
            Card(child: ListTile(title: const Text('Produk'), trailing: Text('$product'))),
            Card(
                child: ListTile(
                    title: const Text('Total Penjualan'),
                    trailing: Text('Rp $total'))),
          ],
        ),
      );
}
