import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ElegantServiceApp());
}

class ElegantServiceApp extends StatelessWidget {
  const ElegantServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Center Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Menggunakan skema warna yang lebih profesional dan elegan (Teal/Blue-Grey)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C), // Warna Teal gelap yang elegan
          brightness: Brightness.light,
        ),
        // Membuat semua form input memiliki desain membulat dan terisi warna abu-abu halus
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        // Desain Card yang lebih lembut tanpa garis keras
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 1; // Default buka di menu Penerimaan untuk testing

  // Daftar Halaman
  final List<Widget> _pages = [
    const DashboardPage(),
    const PenerimaanPage(),
    const AntreanPage(),
    const StokSparepartPage(), // Terhubung ke halaman Stok
    const KasirPage(), // Terhubung ke halaman Kasir
    const LaporanPage(), // Terhubung ke halaman Laporan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background scaffold sedikit abu-abu agar Card putih lebih menonjol (Efek 3D halus)
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Sidebar Navigasi yang lebih rapi
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended:
                true, // Membuka menu menjadi lebar (teks terlihat jelas di desktop)
            minExtendedWidth: 220,
            backgroundColor: Colors.white,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_task),
                selectedIcon: Icon(Icons.add_task),
                label: Text('Penerimaan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.view_kanban_outlined),
                selectedIcon: Icon(Icons.view_kanban),
                label: Text('Antrean'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory),
                label: Text('Stok Sparepart'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.point_of_sale_outlined),
                selectedIcon: Icon(Icons.point_of_sale),
                label: Text('Kasir'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('Laporan'),
              ),
            ],
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.precision_manufacturing,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TechFix',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Area Konten Utama
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                bottomLeft: Radius.circular(32),
              ),
              child: Container(
                color: const Color(0xFFF5F7FA), // Latar belakang abu-abu terang
                child: _pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN PENERIMAAN SERVIS YANG ELEGAN ---
// --- HALAMAN PENERIMAAN SERVIS (DINAMIS & TERHUBUNG KE GOLANG) ---
class PenerimaanPage extends StatefulWidget {
  const PenerimaanPage({super.key});

  @override
  State<PenerimaanPage> createState() => _PenerimaanPageState();
}

class _PenerimaanPageState extends State<PenerimaanPage> {
  // Controllers untuk mengambil teks dari inputan
  final _namaController = TextEditingController();
  final _hpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _modelController = TextEditingController();
  final _keluhanController = TextEditingController();

  String? _selectedKategori;
  String? _selectedMerk;
  bool _isSubmitting = false;

  // Fungsi untuk mengirim data ke Golang
  Future<void> _submitData() async {
    if (_namaController.text.isEmpty || _hpController.text.isEmpty || _selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama, No HP, dan Kategori harus diisi!'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isSubmitting = true; });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_name': _namaController.text,
          'customer_phone': _hpController.text,
          'customer_address': _alamatController.text,
          'device_category': _selectedKategori,
          'device_brand': _selectedMerk ?? 'Lainnya',
          'device_model': _modelController.text,
          'complaint': _keluhanController.text,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final nomorTiket = data['ticket_number'];
        
        if (mounted) {
          // Tampilkan pesan sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berhasil! Nomor Tiket: $nomorTiket'), backgroundColor: Colors.green),
          );
          _bersihkanForm();
        }
      } else {
        throw Exception('Gagal menyimpan (Status ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() { _isSubmitting = false; });
    }
  }

  void _bersihkanForm() {
    _namaController.clear();
    _hpController.clear();
    _alamatController.clear();
    _modelController.clear();
    _keluhanController.clear();
    setState(() {
      _selectedKategori = null;
      _selectedMerk = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Penerimaan Servis Baru', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF2D3748))),
          const SizedBox(height: 8),
          const Text('Catat data pelanggan dan keluhan perangkat dengan detail.', style: TextStyle(fontSize: 16, color: Color(0xFF718096))),
          const SizedBox(height: 40),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom 1: Informasi Pelanggan
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.person_outline, color: Colors.blue.shade700)),
                            const SizedBox(width: 16),
                            const Text('Informasi Pelanggan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 48),
                        TextFormField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama Lengkap Pelanggan', prefixIcon: Icon(Icons.badge_outlined))),
                        const SizedBox(height: 24),
                        TextFormField(controller: _hpController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor WhatsApp', prefixIcon: Icon(Icons.phone_android))),
                        const SizedBox(height: 24),
                        TextFormField(controller: _alamatController, maxLines: 2, decoration: const InputDecoration(labelText: 'Alamat (Opsional)', prefixIcon: Icon(Icons.location_on_outlined))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              
              // Kolom 2: Detail Perangkat
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.devices_other, color: Colors.orange.shade700)),
                            const SizedBox(width: 16),
                            const Text('Detail Perangkat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 48),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Kategori'), value: _selectedKategori,
                                items: ['Pompa Air', 'Kompor Gas', 'Rice Cooker', 'Kipas Angin', 'Lainnya'].map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                                onChanged: (val) => setState(() => _selectedKategori = val),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Merk Barang'), value: _selectedMerk,
                                items: ['Shimizu', 'Rinnai', 'Miyako', 'Sanken', 'Cosmos', 'Lainnya'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (val) => setState(() => _selectedMerk = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: 'Seri / Tipe Model (Opsional)', prefixIcon: Icon(Icons.qr_code))),
                        const SizedBox(height: 24),
                        TextFormField(controller: _keluhanController, maxLines: 3, decoration: const InputDecoration(labelText: 'Keluhan / Deskripsi Kerusakan', alignLabelWithHint: true)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _bersihkanForm,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
                child: const Text('Batalkan', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitData,
                icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.print),
                label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan & Buat Tiket', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// --- HALAMAN DASHBOARD ANALYTICS ---
// --- HALAMAN DASHBOARD ANALYTICS (DINAMIS) ---
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/dashboard'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _stats = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // Fungsi sederhana untuk memformat angka menjadi Rupiah (Titik ribuan)
  String _formatRupiah(double amount) {
    String res = amount.toStringAsFixed(0);
    res = res.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $res';
  }

  // Desain Kartu Statistik Atas
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF718096), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Dashboard Utama', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF2D3748))),
                  SizedBox(height: 8),
                  Text('Ringkasan operasional dan pendapatan bengkel secara real-time.', style: TextStyle(fontSize: 16, color: Color(0xFF718096))),
                ],
              ),
              IconButton(onPressed: _fetchDashboardData, icon: const Icon(Icons.refresh), tooltip: 'Perbarui Data')
            ],
          ),
          const SizedBox(height: 40),
          
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_stats != null) ...[
            // Baris Kartu Statistik
            Row(
              children: [
                _buildStatCard('Total Pendapatan', _formatRupiah((_stats!['total_income'] ?? 0).toDouble()), Icons.account_balance_wallet, Colors.green),
                const SizedBox(width: 24),
                _buildStatCard('Servis Aktif / Antrean', '${_stats!['active_tickets'] ?? 0} Unit', Icons.engineering, Colors.orange),
                const SizedBox(width: 24),
                _buildStatCard('Servis Selesai', '${_stats!['completed_tickets'] ?? 0} Unit', Icons.check_circle_outline, Colors.blue),
              ],
            ),
            const SizedBox(height: 40),
            
            // Tabel Aktivitas Terakhir
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('5 Servis Masuk Terakhir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(height: 32),
                      Expanded(
                        child: (_stats!['recent_tickets'] as List).isEmpty
                          ? const Center(child: Text('Belum ada data servis.', style: TextStyle(color: Colors.grey)))
                          : ListView.separated(
                              itemCount: (_stats!['recent_tickets'] as List).length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final ticket = _stats!['recent_tickets'][index];
                                final status = ticket['status'];
                                
                                // Menentukan warna dan teks status
                                Color statusColor = Colors.grey;
                                String statusText = 'Menunggu';
                                if (status == 'IN_PROGRESS') { statusColor = Colors.orange; statusText = 'Dikerjakan'; }
                                else if (status == 'DONE') { statusColor = Colors.blue; statusText = 'Selesai'; }
                                else if (status == 'COMPLETED') { statusColor = Colors.green; statusText = 'Sudah Diambil'; }

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: statusColor.withOpacity(0.1),
                                    child: Icon(Icons.build, color: statusColor),
                                  ),
                                  title: Text('${ticket['device_category']} ${ticket['device_brand']} (${ticket['ticket_number']})', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('Keluhan: ${ticket['complaint']} | Pelanggan: ${ticket['customer']['name']}'),
                                  trailing: Chip(
                                    label: Text(statusText, style: TextStyle(color: statusColor == Colors.grey ? Colors.black87 : Colors.white, fontSize: 12)), 
                                    backgroundColor: statusColor == Colors.grey ? Colors.grey.shade200 : statusColor,
                                    side: BorderSide.none,
                                  ),
                                );
                              },
                            ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

// --- HALAMAN PAPAN ANTREAN (KANBAN) ---
// --- HALAMAN PAPAN ANTREAN (KANBAN DINAMIS) ---
class AntreanPage extends StatefulWidget {
  const AntreanPage({super.key});

  @override
  State<AntreanPage> createState() => _AntreanPageState();
}

class _AntreanPageState extends State<AntreanPage> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  // Mengambil data tiket dari API Golang
  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/tickets'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tickets = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // Mengubah status tiket
  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:8080/api/tickets/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        _fetchTickets(); // Refresh data otomatis jika sukses
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // Membuat Desain Kolom Kanban
  Widget _buildKanbanColumn(String title, Color color, String targetStatus, List<dynamic> filteredTickets) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text('${filteredTickets.length}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTickets.length,
                itemBuilder: (context, index) {
                  final t = filteredTickets[index];
                  return _buildTicketCard(t);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Membuat Desain Kartu Tiket
  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    String currentStatus = ticket['status'];
    String namaPelanggan = ticket['customer'] != null ? ticket['customer']['name'] : 'Tanpa Nama';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ticket['ticket_number'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
                // Tombol Aksi Pindah Kolom
                if (currentStatus == 'WAITING')
                  TextButton(
                    onPressed: () => _updateStatus(ticket['id'], 'IN_PROGRESS'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), foregroundColor: Colors.orange),
                    child: const Text('Kerjakan ->', style: TextStyle(fontSize: 12)),
                  )
                else if (currentStatus == 'IN_PROGRESS')
                  TextButton(
                    onPressed: () => _updateStatus(ticket['id'], 'DONE'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), foregroundColor: Colors.green),
                    child: const Text('Selesai ->', style: TextStyle(fontSize: 12)),
                  )
              ],
            ),
            const SizedBox(height: 8),
            Text('${ticket['device_category']} ${ticket['device_brand']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(ticket['complaint'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(namaPelanggan, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Memecah tiket ke dalam 3 daftar berdasarkan status
    final waitingTickets = _tickets.where((t) => t['status'] == 'WAITING').toList();
    final inProgressTickets = _tickets.where((t) => t['status'] == 'IN_PROGRESS').toList();
    final doneTickets = _tickets.where((t) => t['status'] == 'DONE').toList();

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Papan Antrean Servis', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF2D3748))),
                  SizedBox(height: 8),
                  Text('Pantau dan ubah status perbaikan perangkat.', style: TextStyle(fontSize: 16, color: Color(0xFF718096))),
                ],
              ),
              IconButton(
                onPressed: _fetchTickets,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
              )
            ],
          ),
          const SizedBox(height: 40),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn('Menunggu Antrean', Colors.grey.shade400, 'WAITING', waitingTickets),
                const SizedBox(width: 24),
                _buildKanbanColumn('Sedang Dikerjakan', Colors.orange, 'IN_PROGRESS', inProgressTickets),
                const SizedBox(width: 24),
                _buildKanbanColumn('Selesai Perbaikan', Colors.green, 'DONE', doneTickets),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- HALAMAN STOK SPAREPART ---
// --- HALAMAN STOK SPAREPART (DINAMIS) ---
// --- HALAMAN STOK SPAREPART (DINAMIS DENGAN FITUR TAMBAH) ---
class StokSparepartPage extends StatefulWidget {
  const StokSparepartPage({super.key});

  @override
  State<StokSparepartPage> createState() => _StokSparepartPageState();
}

class _StokSparepartPageState extends State<StokSparepartPage> {
  List<dynamic> _spareparts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSpareparts();
  }

  // 1. Fungsi mengambil data dari API Golang (GET)
  Future<void> _fetchSpareparts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/spareparts'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _spareparts = jsonResponse['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (Error ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server.\nError: $e';
        _isLoading = false;
      });
    }
  }

  // 2. Fungsi mengirim data baru ke API Golang (POST)
  Future<void> _simpanBarang(String nama, String kategori, int stok, double harga) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/spareparts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nama,
          'category': kategori,
          'stock': stok,
          'price': harga,
        }),
      );

      // Tutup loading dialog
      if (mounted) Navigator.of(context).pop();

      if (response.statusCode == 201) {
        // Tampilkan pesan sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barang berhasil ditambahkan!'), backgroundColor: Colors.green),
          );
        }
        // Refresh daftar barang
        setState(() { _isLoading = true; });
        _fetchSpareparts();
      } else {
        throw Exception('Gagal menyimpan data (Status ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Tutup loading jika error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 3. Fungsi memunculkan Pop-Up Form Tambah Barang
  void _showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    String selectedCategory = 'Pompa Air';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Agar dropdown di dalam dialog bisa di-update
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Sparepart Baru'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400, // Lebar form
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nama Barang'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        value: selectedCategory,
                        items: ['Pompa Air', 'Kompor Gas', 'Rice Cooker', 'Kipas Angin', 'Lainnya']
                            .map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                        onChanged: (val) => setDialogState(() => selectedCategory = val!),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Jumlah Stok'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Harga (Rp)', prefixText: 'Rp '),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    // Validasi sederhana
                    if (nameController.text.isNotEmpty && stockController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      Navigator.pop(context); // Tutup dialog form
                      _simpanBarang(
                        nameController.text,
                        selectedCategory,
                        int.parse(stockController.text),
                        double.parse(priceController.text),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  IconData _getIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('pompa')) return Icons.settings_input_component;
    if (cat.contains('kompor')) return Icons.local_fire_department;
    if (cat.contains('rice cooker')) return Icons.restaurant;
    if (cat.contains('kipas')) return Icons.mode_fan_off;
    return Icons.inventory_2;
  }

  Widget _buildSparepartCard(Map<String, dynamic> item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFE6FFFA), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getIcon(item['category'].toString()), color: const Color(0xFF00695C)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Text('Stok: ${item['stock']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Spacer(),
            Text(item['category'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('Rp ${item['price']}', style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Stok Sparepart', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF2D3748))),
                  SizedBox(height: 8),
                  Text('Kelola inventaris suku cadang bengkel (Live Data).', style: TextStyle(fontSize: 16, color: Color(0xFF718096))),
                ],
              ),
              FilledButton.icon(
                onPressed: _showAddDialog, // <-- Menghubungkan tombol ke pop-up dialog
                icon: const Icon(Icons.add),
                label: const Text('Tambah Barang'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              )
            ],
          ),
          const SizedBox(height: 40),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
                    : _spareparts.isEmpty
                        ? const Center(child: Text('Belum ada data sparepart.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: _spareparts.length,
                            itemBuilder: (context, index) {
                              return _buildSparepartCard(_spareparts[index]);
                            },
                          ),
          )
        ],
      ),
    );
  }
}

// --- HALAMAN KASIR & PEMBAYARAN (LIVE SEARCH - REFACTORED) ---
class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final _searchController = TextEditingController();
  final _totalController = TextEditingController();
  final _bayarController = TextEditingController();

  List<dynamic> _allReadyTickets = [];
  List<dynamic> _filteredTickets = [];
  Map<String, dynamic>? _selectedTicket;
  
  bool _isLoading = true;
  bool _isProcessing = false;
  String _kembalian = "Rp 0";

  @override
  void initState() {
    super.initState();
    _fetchReadyTickets();
  }

  // 1. Fungsi Mengambil Data
  Future<void> _fetchReadyTickets() async {
    setState(() { _isLoading = true; _selectedTicket = null; });
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/tickets'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allTickets = data['data'] as List<dynamic>;
        
        setState(() {
          _allReadyTickets = allTickets.where((t) => t['status'] == 'DONE').toList();
          _filteredTickets = List.from(_allReadyTickets);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // 2. Fungsi Live Search Otomatis
  void _filterTickets(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTickets = List.from(_allReadyTickets);
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredTickets = _allReadyTickets.where((ticket) {
          final ticketNum = ticket['ticket_number'].toString().toLowerCase();
          final customerName = ticket['customer']['name'].toString().toLowerCase();
          return ticketNum.contains(lowerQuery) || customerName.contains(lowerQuery);
        }).toList();
      }
      
      // Batalkan pilihan jika tiket yang dicari tidak ada di layar
      if (_selectedTicket != null && !_filteredTickets.any((t) => t['id'] == _selectedTicket!['id'])) {
        _selectedTicket = null;
      }
    });
  }

  // 3. Fungsi Hitung Kembalian
  void _hitungKembalian(String value) {
    if (_totalController.text.isEmpty || _bayarController.text.isEmpty) {
      setState(() => _kembalian = "Rp 0");
      return;
    }
    try {
      double total = double.parse(_totalController.text);
      double bayar = double.parse(_bayarController.text);
      double kembali = bayar - total;
      setState(() {
        _kembalian = kembali >= 0 ? "Rp ${kembali.toStringAsFixed(0)}" : "Uang Kurang!";
      });
    } catch (e) {
      // Abaikan error konversi angka
    }
  }

  // 4. Fungsi Proses Bayar
  Future<void> _prosesPembayaran() async {
    if (_selectedTicket == null || _totalController.text.isEmpty || _bayarController.text.isEmpty) return;
    
    setState(() => _isProcessing = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ticket_id': _selectedTicket!['id'],
          'total_amount': double.parse(_totalController.text),
          'amount_paid': double.parse(_bayarController.text),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran Berhasil!'), backgroundColor: Colors.green));
          _totalController.clear();
          _bayarController.clear();
          _searchController.clear();
          setState(() => _kembalian = "Rp 0");
          _fetchReadyTickets();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- WIDGET AREA KIRI (DAFTAR TIKET) ---
  Widget _buildAreaKiri() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Menunggu Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: _fetchReadyTickets, icon: const Icon(Icons.refresh)),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _searchController,
              onChanged: _filterTickets,
              decoration: InputDecoration(
                hintText: 'Ketik Nomor Tiket (TCK...) atau Nama Pelanggan...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00695C)),
                suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchController.clear();
                        _filterTickets('');
                      })
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _allReadyTickets.isEmpty
                  ? const Center(child: Text('Belum ada perangkat yang selesai.', style: TextStyle(color: Colors.grey)))
                  : _filteredTickets.isEmpty
                    ? const Center(child: Text('Tidak ada tiket yang cocok.', style: TextStyle(color: Colors.redAccent)))
                    : ListView.builder(
                        itemCount: _filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _filteredTickets[index];
                          final isSelected = _selectedTicket != null && _selectedTicket!['id'] == ticket['id'];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isSelected ? const Color(0xFF00695C) : Colors.grey.shade200, width: isSelected ? 2.0 : 1.0),
                            ),
                            color: isSelected ? const Color(0xFFE6FFFA) : Colors.white,
                            child: ListTile(
                              onTap: () => setState(() => _selectedTicket = ticket),
                              leading: CircleAvatar(
                                backgroundColor: isSelected ? const Color(0xFF00695C) : Colors.grey.shade100,
                                child: Icon(Icons.receipt, color: isSelected ? Colors.white : Colors.grey),
                              ),
                              title: Text('${ticket['ticket_number']} - ${ticket['customer']['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${ticket['device_category']} ${ticket['device_brand']}'),
                              trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00695C)) : const Icon(Icons.chevron_right, color: Colors.grey),
                            ),
                          );
                        },
                      ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET AREA KANAN (PANEL BAYAR) ---
  Widget _buildAreaKanan() {
    return Card(
      color: const Color(0xFF00695C),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: _selectedTicket == null 
          ? const Center(child: Text('Pilih tiket di sebelah kiri\nuntuk mulai pembayaran.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tagihan: ${_selectedTicket!['ticket_number']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${_selectedTicket!['customer']['name']} | ${_selectedTicket!['device_category']}', style: const TextStyle(color: Colors.white70)),
                const Divider(color: Colors.white24, height: 40),
                
                TextFormField(
                  controller: _totalController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Total Biaya (Rp)',
                    labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  onChanged: _hitungKembalian,
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _bayarController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Uang Diterima (Rp)',
                    labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  onChanged: _hitungKembalian,
                ),
                
                const Divider(color: Colors.white24, height: 40),
                const Text('Kembalian', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(_kembalian, style: TextStyle(color: _kembalian == "Uang Kurang!" ? Colors.redAccent : Colors.amberAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_kembalian != "Uang Kurang!" && !_isProcessing) ? _prosesPembayaran : null,
                    icon: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.receipt_long),
                    label: Text(_isProcessing ? 'Memproses...' : 'Selesaikan Pembayaran', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF00695C), backgroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                )
              ],
            ),
      ),
    );
  }

  // --- WIDGET UTAMA HALAMAN ---
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kasir & Pembayaran', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF2D3748))),
          const SizedBox(height: 8),
          const Text('Cari dan pilih perangkat yang sudah selesai untuk pembayaran.', style: TextStyle(fontSize: 16, color: Color(0xFF718096))),
          const SizedBox(height: 40),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildAreaKiri()), // Memanggil fungsi Kiri
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildAreaKanan()), // Memanggil fungsi Kanan
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- HALAMAN LAPORAN KEUANGAN ---
class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Keuangan',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rekapitulasi pendapatan dan performa servis bulan ini.',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Pendapatan',
                  'Rp 4.550.000',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSummaryCard(
                  'Servis Selesai',
                  '42 Unit',
                  Icons.task_alt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSummaryCard(
                  'Sparepart Terjual',
                  '18 Item',
                  Icons.inventory_2,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Ilustrasi Grafik (Placeholder untuk UI Desktop)
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tren Pendapatan Mingguan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Area Grafik Chart akan berada di sini\n(Bisa menggunakan package fl_chart nantinya)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
