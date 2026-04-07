import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ── Config ─────────────────────────────────────────────────
const String baseUrl = 'https://lecture-4-0-csd230-w26-sujit-bolakhe.onrender.com/api/rest';

void main() {
  runApp(const BookstoreApp());
}

// ── App Root ───────────────────────────────────────────────
class BookstoreApp extends StatelessWidget {
  const BookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sujit's Bookstore",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0f1623),
          primary: const Color(0xFF0f1623),
          secondary: const Color(0xFFe8b84b),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0f1623),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ── Auth State ─────────────────────────────────────────────
class AuthState {
  static String? token;
  static bool isAdmin = false;

  static Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': username, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        token = data['token'] ?? data['jwt'] ?? data['accessToken'] ?? data['jwtToken'];
        isAdmin = username == 'admin';
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

// ── Login Screen ───────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController(text: 'user');
  final _passCtrl = TextEditingController(text: 'user');
  bool _loading = false;
  String _error = '';

  Future<void> _login() async {
    setState(() { _loading = true; _error = ''; });
    final ok = await AuthState.login(_userCtrl.text.trim(), _passCtrl.text.trim());
    setState(() => _loading = false);
    if (ok && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => _error = 'Invalid username or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f1623),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book_rounded, size: 72, color: Color(0xFFe8b84b)),
              const SizedBox(height: 16),
              const Text("PageVault", style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold,
                color: Color(0xFFe8b84b), letterSpacing: 1,
              )),
              const Text("Bookstore Admin", style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 48),
              TextField(
                controller: _userCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Username', Icons.person),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Password', Icons.lock),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFe8b84b),
                    foregroundColor: const Color(0xFF0f1623),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Default: admin/admin or user/user', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    prefixIcon: Icon(icon, color: Colors.white38),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFe8b84b)),
    ),
  );
}

// ── Home Screen (Tab Navigation) ───────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _cart = [];

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final existing = _cart.where((c) => c['id'] == item['id'] && c['type'] == item['type']);
      if (existing.isNotEmpty) {
        existing.first['qty'] = (existing.first['qty'] ?? 1) + 1;
      } else {
        _cart.add({...item, 'qty': 1});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item['title']}" added to cart'),
        backgroundColor: const Color(0xFF2eb87a),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      BooksScreen(onAddToCart: _addToCart),
      MagazinesScreen(onAddToCart: _addToCart),
      DvdsScreen(onAddToCart: _addToCart),
      CartScreen(cart: _cart, onCartChanged: () => setState(() {})),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF0f1623),
        indicatorColor: const Color(0xFFe8b84b),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book, color: Colors.white54),
            selectedIcon: const Icon(Icons.menu_book, color: Color(0xFF0f1623)),
            label: 'Books',
          ),
          NavigationDestination(
            icon: const Icon(Icons.newspaper, color: Colors.white54),
            selectedIcon: const Icon(Icons.newspaper, color: Color(0xFF0f1623)),
            label: 'Magazines',
          ),
          NavigationDestination(
            icon: const Icon(Icons.movie, color: Colors.white54),
            selectedIcon: const Icon(Icons.movie, color: Color(0xFF0f1623)),
            label: 'DVDs',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${_cart.fold(0, (sum, i) => sum + (i['qty'] as int))}'),
              isLabelVisible: _cart.isNotEmpty,
              child: const Icon(Icons.shopping_cart, color: Colors.white54),
            ),
            selectedIcon: const Icon(Icons.shopping_cart, color: Color(0xFF0f1623)),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

// ── Books Screen ───────────────────────────────────────────
class BooksScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  const BooksScreen({super.key, required this.onAddToCart});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<dynamic> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/books'), headers: AuthState.headers);
      setState(() { _books = jsonDecode(res.body); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteBook(int id) async {
    await http.delete(Uri.parse('$baseUrl/books/$id'), headers: AuthState.headers);
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          if (AuthState.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AddBookScreen(),
                ));
                _loadBooks();
              },
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBooks),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadBooks,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _books.length,
          itemBuilder: (_, i) {
            final b = _books[i];
            return _ProductCard(
              title: b['title'] ?? '',
              subtitle: 'by ${b['author'] ?? 'Unknown'}',
              price: (b['price'] ?? 0).toDouble(),
              type: 'book',
              color: const Color(0xFF185FA5),
              icon: Icons.menu_book,
              onAddToCart: () => widget.onAddToCart({...b, 'type': 'book'}),
              onDelete: AuthState.isAdmin ? () => _deleteBook(b['id']) : null,
            );
          },
        ),
      ),
    );
  }
}

// ── Magazines Screen ───────────────────────────────────────
class MagazinesScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  const MagazinesScreen({super.key, required this.onAddToCart});

  @override
  State<MagazinesScreen> createState() => _MagazinesScreenState();
}

class _MagazinesScreenState extends State<MagazinesScreen> {
  List<dynamic> _magazines = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadMagazines(); }

  Future<void> _loadMagazines() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/magazines'), headers: AuthState.headers);
      setState(() { _magazines = jsonDecode(res.body); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteMagazine(int id) async {
    await http.delete(Uri.parse('$baseUrl/magazines/$id'), headers: AuthState.headers);
    _loadMagazines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magazines'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMagazines),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadMagazines,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _magazines.length,
          itemBuilder: (_, i) {
            final m = _magazines[i];
            return _ProductCard(
              title: m['title'] ?? '',
              subtitle: 'Publisher: ${m['publisher'] ?? 'Unknown'}',
              price: (m['price'] ?? 0).toDouble(),
              type: 'magazine',
              color: const Color(0xFF0F6E56),
              icon: Icons.newspaper,
              onAddToCart: () => widget.onAddToCart({...m, 'type': 'magazine'}),
              onDelete: AuthState.isAdmin ? () => _deleteMagazine(m['id']) : null,
            );
          },
        ),
      ),
    );
  }
}

// ── DVDs Screen ────────────────────────────────────────────
class DvdsScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  const DvdsScreen({super.key, required this.onAddToCart});

  @override
  State<DvdsScreen> createState() => _DvdsScreenState();
}

class _DvdsScreenState extends State<DvdsScreen> {
  List<dynamic> _dvds = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadDvds(); }

  Future<void> _loadDvds() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/dvds'), headers: AuthState.headers);
      setState(() { _dvds = jsonDecode(res.body); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteDvd(int id) async {
    await http.delete(Uri.parse('$baseUrl/dvds/$id'), headers: AuthState.headers);
    _loadDvds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DVDs'),
        actions: [
          if (AuthState.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AddDvdScreen(),
                ));
                _loadDvds();
              },
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDvds),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDvds,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _dvds.length,
          itemBuilder: (_, i) {
            final d = _dvds[i];
            return _ProductCard(
              title: d['title'] ?? '',
              subtitle: 'Dir. ${d['director'] ?? ''} · ${d['genre'] ?? ''} · ${d['releaseYear'] ?? ''} · ${d['rating'] ?? ''}',
              price: (d['price'] ?? 0).toDouble(),
              type: 'dvd',
              color: const Color(0xFF993C1D),
              icon: Icons.movie,
              onAddToCart: () => widget.onAddToCart({...d, 'type': 'dvd'}),
              onDelete: AuthState.isAdmin ? () => _deleteDvd(d['id']) : null,
            );
          },
        ),
      ),
    );
  }
}

// ── Cart Screen ────────────────────────────────────────────
class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final VoidCallback onCartChanged;
  const CartScreen({super.key, required this.cart, required this.onCartChanged});

  double get _total => cart.fold(0, (sum, i) => sum + (i['price'] ?? 0) * (i['qty'] ?? 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text('Your cart is empty', style: TextStyle(color: Colors.black45)),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.length,
              itemBuilder: (_, i) {
                final item = cart[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0f1623),
                      child: Text('${item['qty']}', style: const TextStyle(color: Color(0xFFe8b84b), fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(item['type']?.toString().toUpperCase() ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${((item['price'] ?? 0) * (item['qty'] ?? 1)).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () { cart.removeAt(i); onCartChanged(); },
                          child: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF0f1623),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text('\$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFFe8b84b), fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cart.clear();
                      onCartChanged();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order placed successfully!'),
                            backgroundColor: Color(0xFF2eb87a)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe8b84b),
                      foregroundColor: const Color(0xFF0f1623),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

// ── Add Book Screen ────────────────────────────────────────
class AddBookScreen extends StatefulWidget {
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await http.post(Uri.parse('$baseUrl/books'),
        headers: AuthState.headers,
        body: jsonEncode({
          'title': _titleCtrl.text,
          'author': _authorCtrl.text,
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'copies': 10,
        }),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save book')));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field(_titleCtrl, 'Title'),
            const SizedBox(height: 14),
            _field(_authorCtrl, 'Author'),
            const SizedBox(height: 14),
            _field(_priceCtrl, 'Price', keyboard: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe8b84b),
                  foregroundColor: const Color(0xFF0f1623),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving ? const CircularProgressIndicator() : const Text('Save Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboard}) =>
      TextField(controller: c, keyboardType: keyboard,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
}

// ── Add DVD Screen ─────────────────────────────────────────
class AddDvdScreen extends StatefulWidget {
  @override
  State<AddDvdScreen> createState() => _AddDvdScreenState();
}

class _AddDvdScreenState extends State<AddDvdScreen> {
  final _titleCtrl = TextEditingController();
  final _directorCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: '2024');
  final _priceCtrl = TextEditingController();
  String _rating = 'PG-13';
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await http.post(Uri.parse('$baseUrl/dvds'),
        headers: AuthState.headers,
        body: jsonEncode({
          'title': _titleCtrl.text,
          'director': _directorCtrl.text,
          'genre': _genreCtrl.text,
          'releaseYear': int.tryParse(_yearCtrl.text) ?? 2024,
          'rating': _rating,
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'copies': 10,
        }),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save DVD')));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add DVD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field(_titleCtrl, 'Title'),
            const SizedBox(height: 14),
            _field(_directorCtrl, 'Director'),
            const SizedBox(height: 14),
            _field(_genreCtrl, 'Genre'),
            const SizedBox(height: 14),
            _field(_yearCtrl, 'Release Year', keyboard: TextInputType.number),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _rating,
              decoration: const InputDecoration(labelText: 'Rating', border: OutlineInputBorder()),
              items: ['G', 'PG', 'PG-13', 'R', 'NC-17', 'NR']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _rating = v!),
            ),
            const SizedBox(height: 14),
            _field(_priceCtrl, 'Price', keyboard: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe8b84b),
                  foregroundColor: const Color(0xFF0f1623),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving ? const CircularProgressIndicator() : const Text('Save DVD'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboard}) =>
      TextField(controller: c, keyboardType: keyboard,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
}

// ── Reusable Product Card ──────────────────────────────────
class _ProductCard extends StatelessWidget {
  final String title, subtitle, type;
  final double price;
  final Color color;
  final IconData icon;
  final VoidCallback onAddToCart;
  final VoidCallback? onDelete;

  const _ProductCard({
    required this.title, required this.subtitle, required this.price,
    required this.type, required this.color, required this.icon,
    required this.onAddToCart, this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('\$${price.toStringAsFixed(2)}',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF2eb87a)),
                  onPressed: onAddToCart,
                  tooltip: 'Add to Cart',
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}