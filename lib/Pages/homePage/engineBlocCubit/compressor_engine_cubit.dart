import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'compressor_engine_state.dart';

class CompressorEngineCubit extends Cubit<CompressorEngineState> {
  CompressorEngineCubit() : super(CompressorEngineInitial());
}
