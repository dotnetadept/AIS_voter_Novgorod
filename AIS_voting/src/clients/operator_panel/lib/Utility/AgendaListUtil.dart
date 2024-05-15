class AgendaListUtil {
  static String getFileName(String folder, int fileIndex) {
    if (folder.contains('д')) {
      return "Вопрос${folder.replaceFirst(' ', '')}_файл${(fileIndex).toString().padLeft(2, '0')}.pdf";
    }
    return "Вопрос${folder.toString().padLeft(2, '0')}_файл${(fileIndex).toString().padLeft(2, '0')}.pdf";
  }
}
