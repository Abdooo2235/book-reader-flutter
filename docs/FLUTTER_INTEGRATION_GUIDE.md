# 📱 Book Reader – Flutter Integration Guide

> **For:** Zeko (Flutter Developer)  
> **From:** Backend Team  
> **Date:** January 2026

---

## 🚀 Quick Start

### Base URL

**Production:**

```
https://book-reader-store-backend.onrender.com/api
```

> ⚠️ Note: Free tier may have ~50s cold start delay after inactivity

### Test Credentials

| Role  | Email                  | Password   |
| ----- | ---------------------- | ---------- |
| Admin | `admin@bookreader.com` | `password` |

---

## 🔐 Authentication

All authenticated endpoints require:

```http
Authorization: Bearer {token}
Accept: application/json
```

### 1. Register

```http
POST /auth/register
Content-Type: application/json

{
    "name": "User Name",
    "email": "user@example.com",
    "password": "password",
    "password_confirmation": "password"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Registration successful",
    "data": {
        "user": { "id": 1, "name": "...", "email": "...", "role": "user" },
        "token": "1|abc123..."
    }
}
```

### 2. Login

```http
POST /auth/login

{
    "email": "user@example.com",
    "password": "password"
}
```

### 3. Logout

```http
POST /auth/logout
Authorization: Bearer {token}
```

### 4. Get Current User

```http
GET /auth/user
Authorization: Bearer {token}
```

---

## 📚 Books (Store Screen)

### List Approved Books

```http
GET /books
GET /books?filter[category_id]=1
GET /books?filter[title]=flutter
GET /books?sort=-average_rating
GET /books?include=category,reviews
GET /books?per_page=15&page=1
```

**Query Parameters:**
| Param | Description | Example |
|-------|-------------|---------|
| `filter[category_id]` | Filter by category | `1` |
| `filter[title]` | Search by title (partial) | `flutter` |
| `filter[author]` | Search by author | `john` |
| `filter[file_type]` | Filter by type | `pdf` or `epub` |
| `sort` | Sort field (prefix `-` for desc) | `-created_at`, `average_rating` |
| `include` | Load relations | `category`, `creator`, `reviews` |
| `per_page` | Items per page | `15` (default) |

**Response:**

```json
{
    "success": true,
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "title": "Flutter Guide",
                "author": "John Doe",
                "description": "...",
                "category_id": 1,
                "cover_url": "http://...",
                "file_type": "pdf",
                "number_of_pages": 250,
                "average_rating": "4.50",
                "status": "approved",
                "category": { "id": 1, "name": "Programming" }
            }
        ],
        "total": 100,
        "per_page": 15,
        "last_page": 7
    }
}
```

### Get Book Details

```http
GET /books/{id}
```

### Get Book Reviews

```http
GET /books/{id}/reviews
```

---

## 📂 Categories

### List All Categories

```http
GET /categories
```

**Response:**

```json
{
    "success": true,
    "data": [
        { "id": 1, "name": "Fiction", "book_count": 25 },
        { "id": 2, "name": "Non-Fiction", "book_count": 18 }
    ]
}
```

---

## 🛒 Cart (Cart Screen)

### View Cart

```http
GET /cart
Authorization: Bearer {token}
```

### Add Book to Cart

```http
POST /cart/books/{book_id}
Authorization: Bearer {token}
```

### Remove Book from Cart

```http
DELETE /cart/books/{book_id}
Authorization: Bearer {token}
```

### Checkout (Place Order)

```http
POST /cart/checkout
Authorization: Bearer {token}
```

**Response:**

```json
{
    "success": true,
    "message": "Order placed successfully!",
    "data": {
        "order": { "id": 1, "total_items": 3 }
    }
}
```

---

## 📥 Library (Library Screen)

### View Downloaded Books

```http
GET /library
Authorization: Bearer {token}
```

### Download Book (Get File URL)

```http
GET /library/{book_id}/download
Authorization: Bearer {token}
```

**Response:**

```json
{
    "success": true,
    "data": {
        "file_url": "https://book-reader-store-backend.onrender.com/storage/...",
        "file_type": "pdf",
        "title": "Flutter Guide",
        "number_of_pages": 250
    }
}
```

---

## ⭐ Favorites

### Add to Favorites

```http
POST /library/{book_id}/favorite
Authorization: Bearer {token}
```

### Remove from Favorites

```http
DELETE /library/{book_id}/favorite
Authorization: Bearer {token}
```

### Get All Favorites

```http
GET /favorites
Authorization: Bearer {token}
```

---

## 🗂️ Collections (Collections Screen)

Default collections created on registration:

-   `Reading`
-   `Already Read`
-   `Planning`
-   `Favorites`

### List Collections

```http
GET /collections
Authorization: Bearer {token}
```

### Get Collection Books

```http
GET /collections/{collection_id}/books
Authorization: Bearer {token}
```

### Add Book to Collection

```http
POST /collections/{collection_id}/books
Authorization: Bearer {token}
Content-Type: application/json

{ "book_id": 1 }
```

### Remove Book from Collection

```http
DELETE /collections/{collection_id}/books/{book_id}
Authorization: Bearer {token}
```

---

## 📖 Reading Progress

### Get All Progress

```http
GET /progress
Authorization: Bearer {token}
```

### Get Book Progress

```http
GET /progress/{book_id}
Authorization: Bearer {token}
```

### Update Progress

```http
PUT /progress/{book_id}
Authorization: Bearer {token}
Content-Type: application/json

{
    "last_page": 50,
    "total_pages": 100
}
```

> Progress percentage is calculated automatically

---

## ⭐ Reviews

### Create Review

```http
POST /books/{book_id}/reviews
Authorization: Bearer {token}
Content-Type: application/json

{
    "rating": 5,
    "review_text": "Great book!"
}
```

### Update Review

```http
PUT /reviews/{review_id}
Authorization: Bearer {token}

{ "rating": 4, "review_text": "Updated review" }
```

### Delete Review

```http
DELETE /reviews/{review_id}
Authorization: Bearer {token}
```

---

## 👤 Profile (Profile Screen)

### Get Profile

```http
GET /profile
Authorization: Bearer {token}
```

**Response includes:**

-   User info (name, email, avatar_url)
-   Reading stats (books_downloaded, currently_reading, completed, reviews_written)

### Update Profile

```http
PUT /profile
Authorization: Bearer {token}
Content-Type: application/json

{ "name": "New Name" }
```

### Upload Avatar

```http
POST /profile/avatar
Authorization: Bearer {token}
Content-Type: multipart/form-data

avatar: (file)
```

### Delete Avatar

```http
DELETE /profile/avatar
Authorization: Bearer {token}
```

---

## ⚙️ Preferences

### Get Preferences

```http
GET /preferences
Authorization: Bearer {token}
```

**Response:**

```json
{
    "success": true,
    "data": {
        "theme": "light",
        "font_size": 16
    }
}
```

### Update Preferences

```http
PUT /preferences
Authorization: Bearer {token}
Content-Type: application/json

{
    "theme": "dark",
    "font_size": 18
}
```

| Field       | Values            |
| ----------- | ----------------- |
| `theme`     | `light` or `dark` |
| `font_size` | `12` - `32`       |

---

## 📤 Submit Book (My Books)

### Submit New Book

```http
POST /books
Authorization: Bearer {token}
Content-Type: multipart/form-data

title: "My Book"
author: "Author Name"
description: "Book description"
category_id: 1
file_type: "pdf"
number_of_pages: 100
book_file: (file, required, max 50MB)
cover_image: (file, optional, max 2MB)
```

### List My Submissions

```http
GET /my-books
Authorization: Bearer {token}
```

### Delete Pending Book

```http
DELETE /my-books/{book_id}
Authorization: Bearer {token}
```

> ⚠️ Can only delete books with `status: pending`

---

## 📊 Response Format

### Success Response

```json
{
    "success": true,
    "message": "Optional message",
    "data": { ... }
}
```

### Error Response

```json
{
    "success": false,
    "message": "Error description",
    "errors": {
        "field": ["Validation error"]
    }
}
```

### HTTP Status Codes

| Code | Meaning          |
| ---- | ---------------- |
| 200  | Success          |
| 201  | Created          |
| 400  | Bad Request      |
| 401  | Unauthorized     |
| 403  | Forbidden        |
| 404  | Not Found        |
| 422  | Validation Error |
| 500  | Server Error     |

---

## 🔄 Flutter Integration Tips

### 1. Dio Setup

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://book-reader-store-backend.onrender.com/api',
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
));

// Add token interceptor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = getStoredToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
));
```

### 2. Token Storage

Store token securely using `flutter_secure_storage`:

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: response.data['token']);
```

### 3. Pagination

```dart
Future<List<Book>> fetchBooks({int page = 1}) async {
  final response = await dio.get('/books', queryParameters: {
    'page': page,
    'per_page': 15,
  });
  return (response.data['data']['data'] as List)
      .map((json) => Book.fromJson(json))
      .toList();
}
```

### 4. File Upload

```dart
Future<void> submitBook(File bookFile, File? coverImage) async {
  final formData = FormData.fromMap({
    'title': 'Book Title',
    'author': 'Author Name',
    'category_id': 1,
    'file_type': 'pdf',
    'book_file': await MultipartFile.fromFile(bookFile.path),
    if (coverImage != null)
      'cover_image': await MultipartFile.fromFile(coverImage.path),
  });

  await dio.post('/books', data: formData);
}
```

---

## 📱 Screen → Endpoint Mapping

| Screen           | Endpoints Used                                                |
| ---------------- | ------------------------------------------------------------- |
| **Splash**       | `GET /auth/user` (check token)                                |
| **Login**        | `POST /auth/login`                                            |
| **Register**     | `POST /auth/register`                                         |
| **Store (Home)** | `GET /books`, `GET /categories`                               |
| **Book Detail**  | `GET /books/{id}`, `POST /cart/books/{id}`                    |
| **Cart**         | `GET /cart`, `DELETE /cart/books/{id}`, `POST /cart/checkout` |
| **Library**      | `GET /library`, `GET /library/{id}/download`                  |
| **Collections**  | `GET /collections`, `GET /collections/{id}/books`             |
| **Reader**       | `PUT /progress/{book_id}`                                     |
| **Profile**      | `GET /profile`, `PUT /profile`, `GET /preferences`            |
| **My Books**     | `GET /my-books`, `POST /books`, `DELETE /my-books/{id}`       |

---

## ✅ Checklist for Zeko

-   [ ] Set `baseUrl` in API service
-   [ ] Implement token storage (secure)
-   [ ] Handle 401 responses (logout user)
-   [ ] Implement pagination for book lists
-   [ ] Test file upload for book submission
-   [ ] Sync reading progress on book close
-   [ ] Handle offline mode gracefully

---

**Questions?** Contact backend team! 🚀
