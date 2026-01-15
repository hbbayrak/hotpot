# Storage Area

## Purpose

Handles file uploads, storage, and retrieval. Supports image resizing and serves files with appropriate content types.

## Routes

- `GET /storage/{fileName}` - Retrieve stored file
- `POST /api/v1/storage/files` - Upload new file

## Controller

### StorageController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/storage/{fileName}` | Public | Get file by name or ID with optional resizing |
| POST | `/api/v1/storage/files` | Authenticated | Upload new file |

**GET Parameters:**
- `fileName` - File name or GUID
- `size` - Optional resize dimensions (e.g., "200x200")

## Services

### IStorageService / StorageService

**File Operations:**
- `SaveFile(storageType, file, ownerId, name)` - Save uploaded file
- `SaveFileApi(storageType, file, ownerId, name)` - Save and return response
- `GetFileById(id)` - Get file entity by ID
- `GetFileByFileName(fileName)` - Get file entity by name
- `GetFileBytes(file)` - Get file content as bytes
- `GetFileStream(file)` - Get file content as stream
- `DeleteFile(file)` - Remove file from storage
- `GetFileApiById(id)` - Get file response DTO
- `GetFilesApiById(ids)` - Get multiple file responses
- `ResolveContentType(fileName)` - Determine MIME type from extension

### IStorageEngine / FilesystemStorageEngine

Low-level file system operations:
- `SaveFileAsync(ownerId, storageType, stream, name)` - Write file to disk
- `GetFileAsync(file)` - Read file from disk
- `GetFileStream(file)` - Open file stream
- `DeleteFile(file)` - Remove file from disk

## Models

### File

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| OwnerId | Guid | User who uploaded |
| StorageTypeId | int | Storage category |
| Name | string | Original file name |
| FileName | string | Stored file name |
| Size | long | File size in bytes |

### StorageType

Storage categories with IDs:
- `Assets` - General asset files

### FileRequest

Upload request model:
- `File` - IFormFile upload
- `StorageTypeId` - Storage category

### FileResponse / FileShortResponse

Response DTOs with URL generation.

## Image Processing

- Uses SixLabors.ImageSharp for resizing
- Resize format: `?size=WIDTHxHEIGHT`
- Maintains aspect ratio
- Resizes only if larger than requested dimensions

## Notes

- Files served with 30-day cache headers
- Content-type resolved from file extension
- Supports: JPEG, PNG, GIF, BMP, WebP
- Unknown types served as `application/octet-stream`
- URLs constructed using `StaticConfiguration.StorageUrl`
