import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_cloudfit/core/constants.dart';

class AddClientScreen extends StatefulWidget {
  static const String name = 'add_client';
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _supabase
          .from('users')
          .select('user_id, name, email, avatar_url')
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .neq('role_id', 2) // Exclude users with coach role; current schema uses role_id
          .limit(10);

      setState(() => _searchResults = List<Map<String, dynamic>>.from(results));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching users: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _assignClient(int userId) async {
    try {
      final myAuthId = _supabase.auth.currentUser!.id;
      final userData = await _supabase
          .from('users')
          .select('user_id')
          .eq('supabase_id', myAuthId)
          .single();
      final myNumericId = userData['user_id'];

      // Check if already assigned
      final existing = await _supabase
          .from('clients')
          .select()
          .eq('user_id', userId)
          .eq('coach_id', myNumericId)
          .maybeSingle();

      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este usuario ya es tu cliente')),
        );
        return;
      }

      await _supabase.from('clients').insert({
        'user_id': userId,
        'coach_id': myNumericId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente asignado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error asignando cliente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "AGREGAR CLIENTE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.cardGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron usuarios',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return Card(
                              color: AppColors.cardGrey,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.cardGrey,
                                  backgroundImage: user['avatar_url'] != null
                                      ? NetworkImage(user['avatar_url'])
                                      : null,
                                  child: user['avatar_url'] == null
                                      ? const Icon(Icons.person, color: Colors.white54)
                                      : null,
                                ),
                                title: Text(
                                  user['name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  user['email'],
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => _assignClient(user['user_id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neonGreen,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('Asignar'),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}