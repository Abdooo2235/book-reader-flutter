# Download & Read Error Diagnosis Guide

## Common Error Scenarios

### 1. **Backend Issues (Most Common)**

#### Error: "Authentication failed. Please log in again."
- **Cause**: 401 Unauthorized - Token expired or invalid
- **Solution**: User needs to log out and log back in
- **Backend Check**: Verify token validation endpoint

#### Error: "You don't have permission to download this book. Please purchase it first."
- **Cause**: 403 Forbidden - Book not purchased or not in library
- **Solution**: User needs to purchase the book first
- **Backend Check**: Verify `/library/{book_id}/download` endpoint checks:
  - User owns the book (purchased)
  - Book exists and is approved
  - User is authenticated

#### Error: "Book not found. It may have been removed."
- **Cause**: 404 Not Found - Book doesn't exist or was deleted
- **Solution**: Book may have been removed from the system
- **Backend Check**: Verify book exists in database

#### Error: "File URL not found in server response"
- **Cause**: Backend response doesn't include `file_url` field
- **Expected Response Format**:
  ```json
  {
    "success": true,
    "data": {
      "file_url": "https://book-reader-store-backend.onrender.com/storage/...",
      "file_type": "pdf",
      "title": "Book Title",
      "number_of_pages": 250
    }
  }
  ```
- **Backend Check**: Ensure response includes `file_url` in the `data` object

### 2. **Frontend Issues**

#### Error: "Request timed out. Please check your internet connection."
- **Cause**: Network timeout or slow connection
- **Solution**: Check internet connection, try again
- **Frontend Check**: Timeout is set to 30 seconds in API config

#### Error: "Book file not available. Please ensure the book is purchased and in your library."
- **Cause**: `file_url` is null or empty in response
- **Solution**: Check backend response structure
- **Frontend Check**: Code looks for `file_url`, `download_url`, or `book_file` fields

## How to Diagnose

### Step 1: Check Console Logs
When you click "Download & Read", check the Flutter console for:
- `Download API response: {...}` - Shows the raw API response
- `Extracted data: {...}` - Shows extracted data object
- `ERROR: ...` - Shows specific error messages

### Step 2: Check Network Request
Use browser DevTools or Flutter DevTools to inspect:
- **Request URL**: `GET /library/{book_id}/download`
- **Request Headers**: Should include `Authorization: Bearer {token}`
- **Response Status**: Should be 200 OK
- **Response Body**: Should contain `file_url`

### Step 3: Verify Backend Response
The backend should return:
```json
{
  "success": true,
  "data": {
    "file_url": "https://book-reader-store-backend.onrender.com/storage/books/123.pdf",
    "file_type": "pdf",
    "title": "Book Title",
    "number_of_pages": 250
  }
}
```

### Step 4: Common Backend Issues

1. **Missing `file_url` field**
   - Backend might not be generating/storing file URLs correctly
   - Check file upload/storage logic

2. **Wrong response structure**
   - Response might be flat instead of nested
   - Code handles both, but prefers nested structure

3. **File doesn't exist**
   - File might have been deleted from storage
   - Check file storage path

4. **Permission issues**
   - User might not have purchased the book
   - Book might not be in user's library
   - Check purchase/library logic

## Testing Checklist

- [ ] User is logged in (has valid token)
- [ ] Book is purchased/added to library
- [ ] Backend returns 200 OK status
- [ ] Response includes `file_url` field
- [ ] `file_url` is a valid, accessible URL
- [ ] File exists at the URL location
- [ ] Network connection is stable

## Quick Fixes

### If error is "File URL not found":
1. Check backend response structure matches expected format
2. Verify `file_url` field exists in response
3. Check file storage is configured correctly

### If error is "Authentication failed":
1. User needs to log out and log back in
2. Check token expiration logic
3. Verify token is being sent in request headers

### If error is "Permission denied":
1. Verify book purchase logic
2. Check if book is in user's library
3. Verify download endpoint permissions

## Debug Mode

The app now includes extensive logging. Check Flutter console for:
- API request/response details
- Extracted data structures
- Error messages with context
- Network error details

