class Note {
  final String noteId;
  final String student;
  final String school;
  final String noteAdderType;
  final String description;

  const Note(
      {required this.noteId,
      required this.student,
      required this.school,
      required this.noteAdderType,
      required this.description});

  factory Note.fromJson(Map<dynamic, dynamic> json) {
    return Note(
      noteId: json['_id'],
      student: json['student'],
      school: json['school'],
      noteAdderType: json['noteAdderType'] == "DRIVER" ? "Şoför" : "Veli",
      description: json['description'],
    );
  }
}
