# Flutter Frontend Implementation Guide

## 📦 Required Packages

Add these to `pubspec.yaml`:

```yaml
dependencies:
    # HTTP & Storage
    dio: ^5.4.0
    path_provider: ^2.1.2
    hive: ^2.2.3
    hive_flutter: ^1.1.0

    # PDF Reading with Highlights
    syncfusion_flutter_pdfviewer: ^24.1.41
```

---

## 🔗 Backend API Endpoints

| Feature                 | Method | Endpoint                         |
| ----------------------- | ------ | -------------------------------- |
| Get Collections         | GET    | `/api/collections`               |
| Get Books in Collection | GET    | `/api/collections/{id}/books`    |
| Add Book to Collection  | POST   | `/api/collections/{id}/books`    |
| Get Download URL        | GET    | `/api/library/{bookId}/download` |
| Save Reading Progress   | PUT    | `/api/progress/{bookId}`         |
| Get Reading Progress    | GET    | `/api/progress/{bookId}`         |
| Get Favorites           | GET    | `/api/favorites`                 |
| Add to Favorites        | POST   | `/api/library/{bookId}/favorite` |

---

## 1️⃣ Library Shelves

Group books by Reading/Completed/Favorites using TabBar:

```dart
class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Reading'),
              Tab(text: 'Completed'),
              Tab(text: 'Favorites'),
              Tab(text: 'Planning'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CollectionBooksView(collectionName: 'Reading'),
            CollectionBooksView(collectionName: 'Already Read'),
            CollectionBooksView(collectionName: 'Favorites'),
            CollectionBooksView(collectionName: 'Planning'),
          ],
        ),
      ),
    );
  }
}
```

---

## 2️⃣ Offline Download

```dart
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class BookDownloadService {
  final Dio _dio = Dio();

  Future<String> downloadBook(String bookId, String pdfUrl) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/books/$bookId.pdf';

    await _dio.download(
      pdfUrl,
      filePath,
      onReceiveProgress: (received, total) {
        double progress = received / total * 100;
        // Update UI with progress
      },
    );

    // Save to Hive
    await Hive.box('downloads').put(bookId, filePath);
    return filePath;
  }

  Future<bool> isDownloaded(String bookId) async {
    return Hive.box('downloads').containsKey(bookId);
  }

  Future<String?> getLocalPath(String bookId) async {
    return Hive.box('downloads').get(bookId);
  }
}
```

---

## 3️⃣ PDF Reader

```dart
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

class BookReaderScreen extends StatefulWidget {
  final String bookId;
  final String? localPath;
  final String? networkUrl;

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final PdfViewerController _controller = PdfViewerController();
  int _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reading')),
      body: widget.localPath != null
          ? SfPdfViewer.file(
              File(widget.localPath!),
              controller: _controller,
              onDocumentLoaded: (details) {
                _totalPages = details.document.pages.count;
              },
              onPageChanged: (details) {
                _saveProgress(details.newPageNumber);
              },
            )
          : SfPdfViewer.network(
              widget.networkUrl!,
              controller: _controller,
            ),
    );
  }

  void _saveProgress(int page) {
    final percentage = (page / _totalPages * 100).round();
    // Call: PUT /api/progress/{bookId}
    // Body: { "current_page": page, "progress_percentage": percentage }
  }
}
```

---

## 4️⃣ Text Highlighting

```dart
class BookReaderWithHighlights extends StatefulWidget {
  final String pdfPath;

  @override
  State<BookReaderWithHighlights> createState() => _State();
}

class _State extends State<BookReaderWithHighlights> {
  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.file(
      File(widget.pdfPath),
      enableTextSelection: true,
      onTextSelectionChanged: (details) {
        if (details.selectedText != null && details.selectedText!.isNotEmpty) {
          _showHighlightMenu(details.selectedText!);
        }
      },
    );
  }

  void _showHighlightMenu(String text) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _colorButton(Colors.yellow, 'Yellow'),
            _colorButton(Colors.green, 'Green'),
            _colorButton(Colors.blue, 'Blue'),
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () => Clipboard.setData(ClipboardData(text: text)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color, String label) {
    return IconButton(
      icon: Icon(Icons.circle, color: color),
      onPressed: () {
        // Save highlight to local storage
        Navigator.pop(context);
      },
    );
  }
}
```

---

## ✅ Checklist

-   [ ] Add packages to pubspec.yaml
-   [ ] Initialize Hive in main.dart
-   [ ] Implement BookDownloadService
-   [ ] Create LibraryScreen with tabs
-   [ ] Implement PDF Reader with SfPdfViewer
-   [ ] Add text selection and highlighting
-   [ ] Save/restore reading progress
-   [ ] Show download progress indicator
