import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/marriage_application_model.dart';

class AdminKUADashboard extends StatelessWidget {
  const AdminKUADashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin KUA'),
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
        stream: firestoreService.getAllApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return const Center(
              child: Text('Belum ada pengajuan'),
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
                    child: Text('${index + 1}'),
                  ),
                  title: Text('${app.groomData.name} & ${app.brideData.name}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${app.statusText}'),
                      Text('ID: ${app.id}'),
                    ],
                  ),
                  trailing: app.status == 'created'
                      ? ElevatedButton(
                          onPressed: () async {
                            await firestoreService.updateApplicationStatus(
                              app.id,
                              'processed',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Status diupdate ke Diproses'),
                                ),
                              );
                            }
                          },
                          child: const Text('Proses'),
                        )
                      : Chip(
                          label: Text(app.statusText),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
