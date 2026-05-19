import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/notifications/notifications_service.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

/// Fires a local notification when a new debit pushes monthly spending over the limit.
class BudgetLimitService {
  BudgetLimitService({
    required NotificationsService notificationsService,
    required TransactionRepository transactionRepository,
  })  : _notificationsService = notificationsService,
        _transactionRepository = transactionRepository;

  final NotificationsService _notificationsService;
  final TransactionRepository _transactionRepository;

  /// Call after a debit transaction has been saved to the database.
  Future<void> onDebitTransactionAdded(double addedAmount) async {
    if (addedAmount <= 0) return;

    const limit = AppConstants.monthlyExpenseLimit;
    final monthlyResult = await _transactionRepository.getMonthlyDebitTotal();

    if (monthlyResult.failure != null || monthlyResult.data == null) return;

    final newTotal = monthlyResult.data!;
    final previousTotal = newTotal - addedAmount;

    if (previousTotal <= limit && newTotal > limit) {
      await _notificationsService.showBudgetLimitExceeded(
        monthlySpent: newTotal,
        limit: limit,
      );
    }
  }
}
