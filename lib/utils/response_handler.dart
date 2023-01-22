import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/utils/snackbar_extension.dart';

mixin DefautltResponseHandler<T extends StatefulWidget> on State<T> {
  Future<void> runRequest<D>(
    Future<D> request,
    void Function(D result) succsess, {
    void Function(Object ex)? fail,
  }) async {
    try {
      succsess(await request);
    } on PostgrestException catch (ex) {
      if (fail != null) {
        fail(ex);
      } else {
        context.showErrorSnackBar(
          message: ex.message,
        );
      }
    } catch (ex) {
      if (fail != null) {
        fail(ex);
      } else {
        if (kDebugMode) {
          context.showErrorSnackBar(
            message: ex.toString(),
          );
        } else {
          context.showErrorSnackBar(
            message: 'Something went wrong, please retry',
          );
        }
      }
    }
  }
}
