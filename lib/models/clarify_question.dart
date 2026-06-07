import 'package:equatable/equatable.dart';

/// A clarifying question Tako asks to better classify a goal (SRS FR-5.2).
class ClarifyQuestion extends Equatable {
  const ClarifyQuestion({required this.question, this.options = const []});

  final String question;
  final List<String> options;

  @override
  List<Object?> get props => [question, options];
}
