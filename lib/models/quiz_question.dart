import 'package:equatable/equatable.dart';

/// A generated multiple-choice quiz question (M13).
class QuizQuestion extends Equatable {
  const QuizQuestion({required this.question, required this.options, required this.answerIndex});

  final String question;
  final List<String> options;
  final int answerIndex;

  @override
  List<Object?> get props => [question, options, answerIndex];
}
