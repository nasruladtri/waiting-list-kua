import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/marriage_application_model.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MarriageApplication>>(
        stream: firestoreService.getUserApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengajuan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Buat pengajuan pernikahan pertama Anda'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(_getStatusIcon(app.status)),
                  ),
                  title: Text('${app.groomData.name} & ${app.brideData.name}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${app.statusText}'),
                      if (app.createdAt != null)
                        Text(
                          'Dibuat: ${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(app.statusText),
                    backgroundColor: _getStatusColor(app.status),
                  ),
                  onTap: () {
                    // TODO: Navigate to detail screen
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create application screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form pengajuan akan segera tersedia'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Pernikahan'),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'created':
        return Icons.schedule;
      case 'processed':
        return Icons.hourglass_empty;
      case 'validated':
        return Icons.check_circle;
      case 'finished':
        return Icons.done_all;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'created':
        return Colors.blue[100]!;
      case 'processed':
        return Colors.orange[100]!;
      case 'validated':
        return Colors.green[100]!;
      case 'finished':
        return Colors.green[300]!;
      case 'rejected':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
