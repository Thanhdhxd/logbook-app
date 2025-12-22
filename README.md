# Logbook App - Ứng dụng quản lý nhật ký canh tác

## Mô tả
Ứng dụng quản lý nhật ký canh tác nông nghiệp với tính năng:
- Quản lý mùa vụ và kế hoạch canh tác
- Nhật ký công việc hàng ngày
- Truy xuất nguồn gốc sản phẩm
- Quản lý vật tư và phân bón

## Công nghệ sử dụng
### Backend
- Node.js + Express
- MongoDB + Mongoose
- Firebase Admin (Push Notifications)

### Frontend
- Flutter (Web/Mobile)
- Dart

## Cài đặt

### Backend
```bash
cd logbook-backend
npm install
cp .env.example .env
# Cập nhật MONGODB_URI trong .env
npm start
```

### Frontend
```bash
cd logbook_app_mobile
flutter pub get
flutter run -d chrome
```

## API Endpoints
- `GET /api/seasons` - Danh sách mùa vụ
- `GET /api/seasons/daily/:seasonId` - Công việc hôm nay
- `POST /api/seasons` - Tạo mùa vụ mới
- `GET /api/traceability/:seasonId` - Truy xuất nguồn gốc

## Database Schema
Xem chi tiết trong `/models`

## License
MIT
flutter build web --release
firebase deploy --only hosting
