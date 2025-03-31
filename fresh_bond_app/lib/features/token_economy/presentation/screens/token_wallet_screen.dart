import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/bond_colors.dart';
import '../../../../core/design/bond_design_system.dart';
import '../../../../core/design/components/bond_button.dart';
import '../../../../core/design/components/bond_card.dart';
import '../../../../core/design/theme/bond_spacing.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/blocs/token_bloc.dart';
import '../../domain/models/token_transaction.dart';

class TokenWalletScreen extends StatefulWidget {
  const TokenWalletScreen({Key? key}) : super(key: key);

  @override
  State<TokenWalletScreen> createState() => _TokenWalletScreenState();
}

class _TokenWalletScreenState extends State<TokenWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TokenBloc _tokenBloc;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tokenBloc = ServiceLocator.tokenBloc;
    
    // Get current user ID and fetch user balance
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final user = await ServiceLocator.authRepository.getCurrentUser();
      if (user != null && user.id.isNotEmpty) {
        _tokenBloc.add(FetchBalanceEvent(userId: user.id));
        _tokenBloc.add(FetchTransactionsEvent(userId: user.id, limit: 20));
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  Future<void> _loadTransactions() async {
    try {
      final user = await ServiceLocator.authRepository.getCurrentUser();
      if (user != null && user.id.isNotEmpty) {
        _tokenBloc.add(FetchTransactionsEvent(userId: user.id, limit: 20));
      }
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }
  
  Future<void> _loadBalance() async {
    try {
      final user = await ServiceLocator.authRepository.getCurrentUser();
      if (user != null && user.id.isNotEmpty) {
        _tokenBloc.add(FetchBalanceEvent(userId: user.id));
      }
    } catch (e) {
      print('Error loading balance: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bond Tokens'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Wallet'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: BlocProvider.value(
        value: _tokenBloc,
        child: BlocBuilder<TokenBloc, TokenState>(
          builder: (context, state) {
            if (state is TokenInitial || state is TokenLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is TokenError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: BondSpacing.md),
                    BondButton(
                      label: 'Retry',
                      onPressed: () async {
                        final user = await ServiceLocator.authRepository.getCurrentUser();
                        final userId = user?.id ?? '';
                        if (userId.isNotEmpty) {
                          _tokenBloc.add(FetchBalanceEvent(userId: userId));
                          _tokenBloc.add(FetchTransactionsEvent(userId: userId, limit: 20));
                        }
                      },
                      variant: BondButtonVariant.secondary,
                    ),
                  ],
                ),
              );
            }
            
            return TabBarView(
              controller: _tabController,
              children: [
                _buildWalletTab(context, state),
                _buildTransactionsTab(context, state),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildWalletTab(BuildContext context, TokenState state) {
    int balance = 0;
    
    if (state is TokenBalanceLoaded) {
      balance = state.balance.balance;
    } else if (state is TokenTransactionsLoaded && state is! TokenBalanceLoaded) {
      // If we only have transactions loaded, fetch balance
      _loadBalance();
    } else if (state is TokenEarned) {
      balance = state.balance.balance;
    } else if (state is TokenSpent) {
      balance = state.balance.balance;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BondSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BondCard(
            child: Column(
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: BondSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.token,
                      size: 32,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: BondSpacing.sm),
                    Text(
                      balance.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BondSpacing.md),
                Text(
                  'Bond Tokens',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BondSpacing.xl),
          const Text(
            'Ways to Earn Tokens',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: BondSpacing.md),
          _buildEarnMethodCard(
            icon: Icons.people,
            title: 'Make Connections',
            description: 'Connect with other professionals to earn tokens',
            tokenValue: '10',
          ),
          const SizedBox(height: BondSpacing.md),
          _buildEarnMethodCard(
            icon: Icons.calendar_today,
            title: 'Schedule Meetings',
            description: 'Schedule and complete meetings to earn tokens',
            tokenValue: '20',
          ),
          const SizedBox(height: BondSpacing.md),
          _buildEarnMethodCard(
            icon: Icons.verified,
            title: 'Verify Meetings',
            description: 'Use NFC verification at in-person meetings',
            tokenValue: '30',
          ),
          const SizedBox(height: BondSpacing.md),
          _buildEarnMethodCard(
            icon: Icons.emoji_events,
            title: 'Earn Achievements',
            description: 'Complete achievements to earn bonus tokens',
            tokenValue: 'Varies',
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarnMethodCard({
    required IconData icon,
    required String title,
    required String description,
    required String tokenValue,
  }) {
    return BondCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(BondSpacing.md),
            decoration: BoxDecoration(
              color: BondColors.primaryLight,
              borderRadius: BorderRadius.circular(BondSpacing.md),
            ),
            child: Icon(
              icon,
              color: BondColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: BondSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: BondSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BondSpacing.md,
              vertical: BondSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(BondSpacing.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.token,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  tokenValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsTab(BuildContext context, TokenState state) {
    List<TokenTransaction> transactions = [];
    
    if (state is TokenTransactionsLoaded) {
      transactions = state.transactions;
    } else if (state is TokenBalanceLoaded && state is! TokenTransactionsLoaded) {
      // If we only have balance loaded, fetch transactions
      _loadTransactions();
      return const Center(child: CircularProgressIndicator());
    }
    
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: BondSpacing.md),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: BondSpacing.sm),
            Text(
              'Start earning tokens to see your transaction history',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(BondSpacing.md),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }
  
  Widget _buildTransactionItem(TokenTransaction transaction) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(transaction.timestamp);
    
    IconData icon;
    Color iconColor;
    String prefix;
    
    switch (transaction.type) {
      case TokenTransactionType.earned:
        icon = Icons.add_circle;
        iconColor = Colors.green;
        prefix = '+';
        break;
      case TokenTransactionType.spent:
        icon = Icons.remove_circle;
        iconColor = Colors.red;
        prefix = '-';
        break;
      case TokenTransactionType.adjusted:
        icon = Icons.settings;
        iconColor = Colors.blue;
        prefix = transaction.amount >= 0 ? '+' : '';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: BondSpacing.md),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
        title: Text(transaction.description),
        subtitle: Text(formattedDate),
        trailing: Text(
          '$prefix${transaction.amount}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}