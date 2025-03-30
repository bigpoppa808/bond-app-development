import 'package:flutter/material.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/features/discover/domain/models/connection_model.dart';

/// Card widget that displays a potential connection
class ConnectionCard extends StatelessWidget {
  final ConnectionModel connection;
  final VoidCallback? onConnect;
  final VoidCallback onViewProfile;

  const ConnectionCard({
    super.key,
    required this.connection,
    this.onConnect,
    required this.onViewProfile,
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
                      
                      // Connection type badge
                      if (connection.type != ConnectionType.other)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getConnectionTypeColor(connection.type),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getConnectionTypeLabel(connection.type),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
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
            
            // Mutual connections
            if (connection.mutualConnections.isNotEmpty) ...[
              Text(
                '${connection.mutualConnections.length} mutual connection${connection.mutualConnections.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: BondAppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View profile button
                OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BondAppTheme.primaryColor,
                    side: BorderSide(color: BondAppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('View Profile'),
                ),
                const SizedBox(width: 8),
                
                // Connect button
                if (onConnect != null)
                  ElevatedButton(
                    onPressed: onConnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BondAppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Connect'),
                  )
                else
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Connected'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get color for connection type badge
  Color _getConnectionTypeColor(ConnectionType type) {
    switch (type) {
      case ConnectionType.family:
        return Colors.purple;
      case ConnectionType.friend:
        return Colors.green;
      case ConnectionType.colleague:
        return Colors.blue;
      case ConnectionType.acquaintance:
        return Colors.orange;
      case ConnectionType.other:
        return Colors.grey;
    }
  }
  
  /// Get label for connection type badge
  String _getConnectionTypeLabel(ConnectionType type) {
    switch (type) {
      case ConnectionType.family:
        return 'Family';
      case ConnectionType.friend:
        return 'Friend';
      case ConnectionType.colleague:
        return 'Colleague';
      case ConnectionType.acquaintance:
        return 'Acquaintance';
      case ConnectionType.other:
        return 'Other';
    }
  }
}
