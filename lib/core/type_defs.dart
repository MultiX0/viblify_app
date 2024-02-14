import 'package:fpdart/fpdart.dart';
import 'package:viblify_app/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
