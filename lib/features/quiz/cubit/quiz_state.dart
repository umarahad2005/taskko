part of 'quiz_cubit.dart';

enum QuizStep { input, loading, taking, result }

class QuizState extends Equatable {
  const QuizState({
    this.step = QuizStep.input,
    this.topic = '',
    this.questions = const [],
    this.currentIndex = 0,
    this.selected = const [],
    this.error,
  });

  final QuizStep step;
  final String topic;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final List<int?> selected;
  final String? error;

  QuizQuestion? get current =>
      questions.isEmpty || currentIndex >= questions.length ? null : questions[currentIndex];

  bool get isLast => currentIndex >= questions.length - 1;

  int get score {
    var s = 0;
    for (var i = 0; i < questions.length; i++) {
      if (i < selected.length && selected[i] == questions[i].answerIndex) s++;
    }
    return s;
  }

  QuizState copyWith({
    QuizStep? step,
    String? topic,
    List<QuizQuestion>? questions,
    int? currentIndex,
    List<int?>? selected,
    String? error,
  }) =>
      QuizState(
        step: step ?? this.step,
        topic: topic ?? this.topic,
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        selected: selected ?? this.selected,
        error: error,
      );

  @override
  List<Object?> get props => [step, topic, questions, currentIndex, selected, error];
}
