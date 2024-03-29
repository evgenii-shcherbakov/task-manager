import 'package:frontend/models/comment.dart';
import 'package:frontend/state/base/sharable_state.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class CommentState extends SharableState<Comment> {}
