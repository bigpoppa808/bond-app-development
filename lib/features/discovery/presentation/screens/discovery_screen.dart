import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bond_app/core/managers/location_manager.dart';
import 'package:bond_app/features/discovery/data/repositories/discovery_repository.dart';
import 'package:bond_app/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:bond_app/features/discovery/presentation/widgets/discovery_filter_bar.dart';
import 'package:bond_app/features/discovery/presentation/widgets/profile_card.dart';
import 'package:bond_app/features/discovery/presentation/widgets/radius_selector.dart';
import 'package:bond_app/features/profile/domain/models/profile_model.dart';
import 'package:get_it/get_it.dart';

/// Screen for discovering other users
class DiscoveryScreen extends StatefulWidget {
  /// Constructor
  const DiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedInterests = [];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscoveryBloc(
        discoveryRepository: GetIt.I<DiscoveryRepository>(),
        locationManager: GetIt.I<LocationManager>(),
      )..add(const StartDiscovery()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DiscoveryBloc>().add(const RefreshDiscovery());
              },
            ),
          ],
        ),
        body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
          builder: (context, state) {
            if (state is DiscoveryInitial || state is DiscoveryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DiscoveryError) {
              return _buildErrorView(context, state.message);
            } else if (state is DiscoveryLoaded) {
              return _buildDiscoveryView(context, state);
            } else if (state is DiscoverySearchResults) {
              return _buildSearchResultsView(context, state);
            } else if (state is DiscoveryInterestResults) {
              return _buildInterestResultsView(context, state);
            }
            
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
  
  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<DiscoveryBloc>().add(const StartDiscovery());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDiscoveryView(BuildContext context, DiscoveryLoaded state) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search profiles',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                context.read<DiscoveryBloc>().add(SearchProfiles(query: query));
              }
            },
          ),
        ),
        
        // Filter bar
        DiscoveryFilterBar(
          selectedInterests: _selectedInterests,
          onInterestsChanged: (interests) {
            setState(() {
              _selectedInterests.clear();
              _selectedInterests.addAll(interests);
            });
            
            if (interests.isNotEmpty) {
              context.read<DiscoveryBloc>().add(FilterByInterests(
                interests: interests,
              ));
            } else {
              context.read<DiscoveryBloc>().add(const RefreshDiscovery());
            }
          },
        ),
        
        // Radius selector
        RadiusSelector(
          currentRadius: state.radiusInMeters,
          onRadiusChanged: (radius) {
            context.read<DiscoveryBloc>().add(SetDiscoveryRadius(radius));
          },
        ),
        
        // Location info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Showing profiles within ${(state.radiusInMeters / 1000).toStringAsFixed(1)} km of your location',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Found ${state.profiles.length} profiles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (state.filteredByInterests != null && state.filteredByInterests!.isNotEmpty)
                Chip(
                  label: Text('Filtered by ${state.filteredByInterests!.length} interests'),
                  onDeleted: () {
                    setState(() {
                      _selectedInterests.clear();
                    });
                    context.read<DiscoveryBloc>().add(const RefreshDiscovery());
                  },
                ),
            ],
          ),
        ),
        
        // Profile grid
        Expanded(
          child: state.profiles.isEmpty
              ? _buildEmptyView(context)
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.profiles.length,
                  itemBuilder: (context, index) {
                    final profile = state.profiles[index];
                    return ProfileCard(
                      profile: profile,
                      distance: _calculateDistance(
                        state.currentPosition,
                        profile,
                      ),
                      onTap: () => _navigateToProfileDetail(context, profile),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildSearchResultsView(BuildContext context, DiscoverySearchResults state) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search profiles',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<DiscoveryBloc>().add(const StartDiscovery());
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                context.read<DiscoveryBloc>().add(SearchProfiles(query: query));
              } else {
                context.read<DiscoveryBloc>().add(const StartDiscovery());
              }
            },
          ),
        ),
        
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Search results for "${state.query}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text('${state.profiles.length} results'),
            ],
          ),
        ),
        
        // Back button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              context.read<DiscoveryBloc>().add(const StartDiscovery());
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Discovery'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ),
        
        // Profile grid
        Expanded(
          child: state.profiles.isEmpty
              ? _buildEmptyView(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.profiles.length,
                  itemBuilder: (context, index) {
                    final profile = state.profiles[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profile.photos.isNotEmpty
                            ? NetworkImage(profile.photos.first)
                            : null,
                        child: profile.photos.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(profile.name),
                      subtitle: Text(profile.occupation ?? ''),
                      onTap: () => _navigateToProfileDetail(context, profile),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildInterestResultsView(BuildContext context, DiscoveryInterestResults state) {
    return Column(
      children: [
        // Filter bar
        DiscoveryFilterBar(
          selectedInterests: state.interests,
          onInterestsChanged: (interests) {
            if (interests.isNotEmpty) {
              context.read<DiscoveryBloc>().add(FilterByInterests(
                interests: interests,
              ));
            } else {
              context.read<DiscoveryBloc>().add(const StartDiscovery());
            }
          },
        ),
        
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Filtered by interests: ${state.interests.join(", ")}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text('${state.profiles.length} results'),
            ],
          ),
        ),
        
        // Back button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedInterests.clear();
              });
              context.read<DiscoveryBloc>().add(const StartDiscovery());
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Discovery'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ),
        
        // Profile grid
        Expanded(
          child: state.profiles.isEmpty
              ? _buildEmptyView(context)
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.profiles.length,
                  itemBuilder: (context, index) {
                    final profile = state.profiles[index];
                    return ProfileCard(
                      profile: profile,
                      onTap: () => _navigateToProfileDetail(context, profile),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No profiles found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search criteria',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  String _calculateDistance(Position currentPosition, ProfileModel profile) {
    if (profile.latitude == null || profile.longitude == null) {
      return 'Unknown';
    }
    
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      profile.latitude!,
      profile.longitude!,
    );
    
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }
  
  void _navigateToProfileDetail(BuildContext context, ProfileModel profile) {
    // Navigate to profile detail screen
    Navigator.of(context).pushNamed('/profile/${profile.id}');
  }
}
