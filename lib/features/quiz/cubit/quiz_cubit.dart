import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/quiz_question.dart';
import '../../../repositories/ai_tools_repository.dart';

part 'quiz_state.dart';

/// AI quiz generator (M13): topic → quiz → take → score.
class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._repo) : super(const QuizState());

  final AiToolsRepository _repo;

  void setTopic(String value) => emit(state.copyWith(topic: value));

  Future<void> generate({int count = 5, String difficulty = 'medium'}) async {
    final topic = state.topic.trim();
    if (topic.length < 2) {
      emit(state.copyWith(error: 'Enter a topic to study'));
      return;
    }
    emit(state.copyWith(step: QuizStep.loading, error: null));
    try {
      final questions = await _repo.generateQuiz(topic: topic, count: count, difficulty: difficulty);
      emit(state.copyWith(
        step: QuizStep.taking,
        questions: questions,
        currentIndex: 0,
        selected: List<int?>.filled(questions.length, null),
      ));
    } catch (e) {
      emit(state.copyWith(step: QuizStep.input, error: e.toString()));
    }
  }

  void select(int optionIndex) {
    final sel = List<int?>.of(state.selected);
    sel[state.currentIndex] = optionIndex;
    emit(state.copyWith(selected: sel));
  }

  void next() {
    if (state.currentIndex < state.questions.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    } else {
      emit(state.copyWith(step: QuizStep.result));
    }
  }

  void restart() => emit(const QuizState());
}
