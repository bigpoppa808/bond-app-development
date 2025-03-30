import 'package:flutter/material.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/features/discover/domain/models/connection_model.dart';

/// Card widget that displays a pending connection request
class PendingRequestCard extends StatelessWidget {
  final ConnectionModel connection;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PendingRequestCard({
    super.key,
    required this.connection,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: BondAppTheme.primaryColor.withOpacity(0.1),
                  child: connection.avatarUrl != null
                      ? null // In a real app, would load the image
                      : Icon(
                          Icons.person,
                          size: 30,
                          color: BondAppTheme.primaryColor,
                        ),
                ),
                const SizedBox(width: 16),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connection.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Request label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Wants to connect',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Mutual connections
                      if (connection.mutualConnections.isNotEmpty)
                        Text(
                          '${connection.mutualConnections.length} mutual connection${connection.mutualConnections.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: BondAppTheme.textSecondary,
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Bio
                      if (connection.bio != null)
                        Text(
                          connection.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            color: BondAppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Reject button
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BondAppTheme.errorColor,
                    side: BorderSide(color: BondAppTheme.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 12),
                
                // Accept button
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BondAppTheme.successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
