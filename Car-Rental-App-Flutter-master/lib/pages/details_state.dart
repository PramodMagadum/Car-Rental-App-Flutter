import 'package:flutter_bloc/flutter_bloc.dart';

class detialedCubit extends Cubit<bool?>{
  detialedCubit( bool initialState) : super(null);

    void change(bool? status){
      emit(status);
    }

}