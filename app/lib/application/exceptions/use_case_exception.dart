/// Application層のビジネスエラー階層
///
/// ArgumentError を継承して既存テスト（throwsArgumentError）との
/// 後方互換性を維持しつつ、エラー種別を型で識別可能にする。
///
/// Presentation層ではこれらの型で switch 分岐してユーザー向け
/// メッセージを出しわけることができる。
sealed class UseCaseException extends ArgumentError {
  UseCaseException(super.message);

  @override
  String toString() => '$runtimeType: ${message ?? ''}';
}

/// 入力値バリデーションエラー（空ID、不正フォーマット等）
class ValidationException extends UseCaseException {
  ValidationException(super.message);
}

/// 対象エンティティが見つからない
class NotFoundException extends UseCaseException {
  NotFoundException(super.message);
}

/// ビジネスルール違反（完了済み更新禁止等）
class BusinessRuleException extends UseCaseException {
  BusinessRuleException(super.message);
}
