import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logistics/data/models/customer_order_model.dart';
import 'package:logistics/domain/repositories/customer_order_repository.dart';

part 'customer_order_event.dart';
part 'customer_order_state.dart';

class CustomerOrderBloc extends Bloc<CustomerOrderEvent, CustomerOrderState> {
  final CustomerOrderRepository _customerOrderRepository;

  CustomerOrderBloc({required CustomerOrderRepository customerOrderRepository})
    : _customerOrderRepository = customerOrderRepository,
      super(CustomerOrderInitial()) {
    on<LoadCustomerOrders>(_onLoadCustomerOrders);
    on<CreateCustomerOrder>(_onCreateCustomerOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<LoadOrdersByStatus>(_onLoadOrdersByStatus);
  }

  Future<void> _onLoadCustomerOrders(
    LoadCustomerOrders event,
    Emitter<CustomerOrderState> emit,
  ) async {
    emit(CustomerOrderLoading());
    try {
      await emit.forEach<List<CustomerOrderModel>>(
        _customerOrderRepository.getCustomerOrders(),
        onData: (orders) => CustomerOrderLoaded(orders),
        onError: (error, stackTrace) => CustomerOrderError(error.toString()),
      );
    } catch (e) {
      emit(CustomerOrderError(e.toString()));
    }
  }

  Future<void> _onCreateCustomerOrder(
    CreateCustomerOrder event,
    Emitter<CustomerOrderState> emit,
  ) async {
    emit(CustomerOrderLoading());
    try {
      await _customerOrderRepository.createCustomerOrder(event.order);
      emit(CustomerOrderCreated());
      add(LoadCustomerOrders());
    } catch (e) {
      emit(CustomerOrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<CustomerOrderState> emit,
  ) async {
    try {
      await _customerOrderRepository.updateOrderStatus(event.orderId, event.status);
      add(LoadCustomerOrders());
    } catch (e) {
      emit(CustomerOrderError(e.toString()));
    }
  }

  Future<void> _onLoadOrdersByStatus(
    LoadOrdersByStatus event,
    Emitter<CustomerOrderState> emit,
  ) async {
    emit(CustomerOrderLoading());
    try {
      await emit.forEach<List<CustomerOrderModel>>(
        _customerOrderRepository.getCustomerOrdersByStatus(event.status),
        onData: (orders) => CustomerOrderLoaded(orders),
        onError: (error, stackTrace) => CustomerOrderError(error.toString()),
      );
    } catch (e) {
      emit(CustomerOrderError(e.toString()));
    }
  }
}
