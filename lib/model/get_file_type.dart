enum FileType { video, audio, image, text, word, ntd, otherwise }

class GetFileType {
  final String _filePath;

  GetFileType(this._filePath);

  FileType get fileType {
    if (_isImage) {
      return FileType.image;
    } else if (_isText) {
      return FileType.text;
    } else if (_isNTD) {
      return FileType.ntd;
    } else if (_isWord) {
      return FileType.word;
    } else if (_isVideo) {
      return FileType.video;
    } else if (_isAudio) {
      return FileType.audio;
    } else {
      return FileType.otherwise;
    }
  }

  bool get _isImage {
    List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];

    return imageExtensions.contains(getFileExtension);
  }

  bool get _isVideo {
    List<String> imageExtensions = ['mp4'];

    return imageExtensions.contains(getFileExtension);
  }

  bool get _isAudio {
    List<String> imageExtensions = ['mp3'];

    return imageExtensions.contains(getFileExtension);
  }

  bool get _isText {
    List<String> textExtensions = ['txt'];

    return textExtensions.contains(getFileExtension);
  }

  bool get _isNTD {
    List<String> textExtensions = ['ntd'];

    return textExtensions.contains(getFileExtension);
  }

  bool get _isWord {
    List<String> textExtensions = ["pdf"];

    return textExtensions.contains(getFileExtension);
  }

  String get getFileExtension => _filePath.split('.').last;
}
