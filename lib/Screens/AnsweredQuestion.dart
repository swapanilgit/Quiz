class AnsweredQuestion {
  final String question;
  final String correctAnswer;
  final String userAnswer;

  const AnsweredQuestion({
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
  });
  
  bool get isCorrect => correctAnswer == userAnswer;
}