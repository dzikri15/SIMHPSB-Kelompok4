// lib/screens/distribusi_histori_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/tujuan_distribusi_model.dart';
import '../services/tujuan_distribusi_service.dart';

class DistribusiHistoriScreen extends StatefulWidget {
  final TujuanDistribusiModel tujuan;

  const DistribusiHistoriScreen({super.key, required this.tujuan});

  @override
  State<DistribusiHistoriScreen> createState() => _DistribusiHistoriScreenState();
}

class _DistribusiHistoriScreenState extends State<DistribusiHistoriScreen> {
  final TujuanDistribusiService _tujuanService = TujuanDistribusiService();
  final ScrollController _scrollController = ScrollController();
  
  List<dynamic> _historiList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchData();
    }
  }

  Future<void> _fetchData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _historiList.clear();
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await _tujuanService.getHistori(widget.tujuan.id, page: _currentPage);
      final data = response['data'] as List;

      setState(() {
        _currentPage++;
        _historiList.addAll(data);
        if (data.isEmpty || data.length < 15) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatNumber = NumberFormat('#,##0', 'id_ID');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Histori: ${widget.tujuan.nama}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _historiList.isEmpty && !_isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pengiriman',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _fetchData(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _historiList.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _historiList.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final item = _historiList[index];
                  final tanggal = item['tanggal'] ?? item['tanggal_update'] ?? item['created_at'];
                  final formattedDate = tanggal != null 
                      ? DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(tanggal))
                      : '-';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['komoditas'] ?? 'Beras',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.local_shipping, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${formatNumber.format(num.tryParse(item['jumlah'].toString()) ?? 0)} Kg',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (item['keterangan'] != null && item['keterangan'].toString().trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              item['keterangan'],
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
