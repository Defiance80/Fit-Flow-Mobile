import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/models/data_class.dart';
import 'package:fitflow/features/coupon/models/coupon_model.dart';
import 'package:fitflow/features/coupon/repository/coupon_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchCouponsState {}

class FetchCouponsInitial extends FetchCouponsState {}

class FetchCouponsInProgress extends FetchCouponsState {}

class FetchCouponsSuccess extends FetchCouponsState {
  final List<CouponModel> coupons;
  FetchCouponsSuccess(this.coupons);
}

final class FetchCouponsFail extends ErrorState implements FetchCouponsState {
  FetchCouponsFail({required super.error});
}

class FetchCouponsCubit extends Cubit<FetchCouponsState> {
  final CouponListTarget target;
  final int? courseId;
  final CouponRepository _repository = CouponRepository();
  FetchCouponsCubit(this.target, this.courseId) : super(FetchCouponsInitial());
  Future<void> fetch() async {
    try {
      emit(FetchCouponsInProgress());

      final DataClass<CouponModel> dataClass = await _repository.fetchCoupons(
        courseId: courseId,
        target: target,
      );

      emit(FetchCouponsSuccess(dataClass.data));
    } catch (e) {
      emit(FetchCouponsFail(error: e));
    }
  }
}
