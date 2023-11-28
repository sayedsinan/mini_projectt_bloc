
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_project_bloc/app/app_observer.dart';
import 'package:mini_project_bloc/store/view/store_app_cubit.dart';

void main() {
  Bloc.observer = AppObserver();

  runApp(const StoreAppCubit());
}