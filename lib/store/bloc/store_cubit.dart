
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_project_bloc/store/bloc/store_state.dart';
import 'package:mini_project_bloc/store/repository/store_repository.dart';

class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(const StoreState());

  final StoreRepository api = StoreRepository();

  Future<void> loadProducts() async {
    try {
      emit(state.copyWith(
        productsStatus: StoreRequest.requestInProgress,
      ));

      final response = await api.getProducts();

      emit(state.copyWith(
        productsStatus: StoreRequest.requestSuccess,
        products: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        productsStatus: StoreRequest.requestFailure,
      ));
    }
  }

  void addToCart(int cartId) {
    emit(state.copyWith(cartIds: {...state.cartIds, cartId}));
  }

  void removeFromCart(int cartId) {
    emit(state.copyWith(cartIds: {...state.cartIds}..remove(cartId)));
  }
}