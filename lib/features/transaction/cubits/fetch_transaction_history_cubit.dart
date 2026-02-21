import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/models/data_class.dart';
import 'package:fitflow/features/transaction/models/transaction_history_model.dart';
import 'package:fitflow/features/transaction/repositories/transaction_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchTransactionHistoryState {}

class FetchTransactionHistoryInitial extends FetchTransactionHistoryState {}

class FetchTransactionHistoryInProgress extends FetchTransactionHistoryState {}

class FetchTransactionHistorySuccess
    extends SuccessState<TransactionHistoryModel>
    implements FetchTransactionHistoryState {
  FetchTransactionHistorySuccess({required super.data});
}

final class FetchTransactionHistoryFail extends ErrorState
    implements FetchTransactionHistoryState {
  FetchTransactionHistoryFail({required super.error});
}

class FetchTransactionHistoryCubit extends Cubit<FetchTransactionHistoryState> {
  final TransactionHistoryRepository _repository;
  FetchTransactionHistoryCubit(this._repository)
      : super(FetchTransactionHistoryInitial());

  void fetch() async {
    try {
      emit(FetchTransactionHistoryInProgress());
      final DataClass<TransactionHistoryModel> result =
          await _repository.fetch();
      emit(FetchTransactionHistorySuccess(data: result.data));
    } catch (e) {
      emit(FetchTransactionHistoryFail(error: e));
    }
  }
}
