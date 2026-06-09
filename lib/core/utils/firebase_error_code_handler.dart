import 'package:horti_vige/data/enums/firebase_enums.dart';

class FirebaseErrorCodeHandler {
  FirebaseErrorCodeHandler._();

  static FirebaseErrorCode mapErrorCode(String code) {
    switch (code.toLowerCase()) {
      case 'invalid-email':
        return FirebaseErrorCode.invalidEmail;
      case 'user-not-found':
        return FirebaseErrorCode.userNotFound;
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return FirebaseErrorCode.wrongPassword;
      case 'user-disabled':
        return FirebaseErrorCode.userDisabled;
      case 'email-already-in-use':
        return FirebaseErrorCode.emailAlreadyInUse;
      case 'weak-password':
        return FirebaseErrorCode.weakPassword;
      case 'operation-not-allowed':
        return FirebaseErrorCode.operationNotAllowed;
      case 'user-token-expired':
        return FirebaseErrorCode.userTokenExpired;
      case 'user-token-invalid':
        return FirebaseErrorCode.userTokenInvalid;
      case 'too-many-requests':
        return FirebaseErrorCode.tooManyRequests;
      case 'permission-denied':
        return FirebaseErrorCode.permissionDenied;
      case 'not-found':
        return FirebaseErrorCode.notFound;
      case 'aborted':
        return FirebaseErrorCode.aborted;
      case 'already-exists':
        return FirebaseErrorCode.alreadyExists;
      case 'resource-exhausted':
        return FirebaseErrorCode.resourceExhausted;
      case 'failed-precondition':
        return FirebaseErrorCode.failedPrecondition;
      case 'invalid-argument':
        return FirebaseErrorCode.invalidArgument;
      case 'unauthenticated':
        return FirebaseErrorCode.unauthenticated;
      case 'unavailable':
        return FirebaseErrorCode.unavailable;
      default:
        return FirebaseErrorCode.unknown;
    }
  }

  static String getMessage(FirebaseErrorCode code) {
    switch (code) {
      case FirebaseErrorCode.invalidEmail:
        return 'The email address is not valid.';
      case FirebaseErrorCode.userNotFound:
        return 'This email is not registered';
      case FirebaseErrorCode.wrongPassword:
        return 'Email or password is incorrect. Reset password if you forgot it.';
      case FirebaseErrorCode.userDisabled:
        return 'The user has been disabled.';
      case FirebaseErrorCode.emailAlreadyInUse:
        return 'The email address is already in use by another account.';
      case FirebaseErrorCode.weakPassword:
        return 'The password is too weak.';
      case FirebaseErrorCode.operationNotAllowed:
        return 'This operation is not allowed.';
      case FirebaseErrorCode.userTokenExpired:
        return 'The user token has expired.';
      case FirebaseErrorCode.userTokenInvalid:
        return 'The user token is invalid.';
      case FirebaseErrorCode.tooManyRequests:
        return 'Too many requests. Try again later.';
      case FirebaseErrorCode.permissionDenied:
        return 'You do not have permission to access this resource.';
      case FirebaseErrorCode.notFound:
        return 'The resource you are trying to access does not exist.';
      case FirebaseErrorCode.aborted:
        return 'The operation was aborted due to a network error.';
      case FirebaseErrorCode.alreadyExists:
        return 'The resource you are trying to create already exists.';
      case FirebaseErrorCode.resourceExhausted:
        return 'You have exceeded your quota for this resource.';
      case FirebaseErrorCode.failedPrecondition:
        return 'The precondition for this operation was not met.';
      case FirebaseErrorCode.invalidArgument:
        return 'The argument provided is invalid.';
      case FirebaseErrorCode.unauthenticated:
        return 'You are not authenticated.';
      case FirebaseErrorCode.unavailable:
        return 'The service is currently unavailable.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
