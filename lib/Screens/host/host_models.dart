enum HostDifficulty { easy, medium, hard }

class HostQuestionDraft {
  String question;
  List<String> options;
  int correctIndex;

  HostQuestionDraft({
    this.question = '',
    List<String>? options,
    this.correctIndex = 0,
  }) : options = options ?? ['', '', '', ''];
}
