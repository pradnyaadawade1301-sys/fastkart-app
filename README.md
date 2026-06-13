# FastKart Backend API

## Setup

### 1. PostgreSQL Setup
```bash
psql -U postgres
CREATE DATABASE fastkart;
\q

psql -U postgres -d fastkart -f migrations/001_init.sql
```

### 2. .env configure karo
```
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=fastkart
JWT_SECRET=your_secret_key
PORT=8080
```

### 3. Run karo
```bash
cd fastkart-backend
go mod tidy
go run cmd/main.go
```

---

## API Endpoints

### Auth (Public)
| Method | URL | Description |
|--------|-----|-------------|
| POST | /auth/send-otp | OTP bhejo |
| POST | /auth/verify-otp | OTP verify karo, token milega |

### Restaurants (Public)
| Method | URL | Description |
|--------|-----|-------------|
| GET | /api/restaurants | List with filters |
| GET | /api/restaurants/nearby?lat=&lng= | Nearby restaurants |
| GET | /api/restaurants/:id | Single restaurant |
| GET | /api/restaurants/:id/menu | Restaurant menu |

### Orders (Auth required)
| Method | URL | Description |
|--------|-----|-------------|
| POST | /api/orders | Place order |
| GET | /api/orders | My orders |
| GET | /api/orders/:id | Order detail |
| PUT | /api/orders/:id/cancel | Cancel order |
| GET | /api/orders/:id/track | Live tracking |

### User (Auth required)
| Method | URL | Description |
|--------|-----|-------------|
| GET | /api/me | My profile |
| PUT | /api/me | Update profile |
| GET | /api/me/addresses | My addresses |
| POST | /api/me/addresses | Add address |
| GET | /api/me/wallet | Wallet & transactions |

---

## Flutter mein use karo

```dart
// auth_provider.dart mein
final response = await http.post(
  Uri.parse('http://localhost:8080/auth/verify-otp'),
  body: jsonEncode({'phone': phone, 'otp': otp, 'role': 'customer'}),
);
final token = response['token'];
```

## Headers (protected routes)
```
Authorization: Bearer <token>
Content-Type: application/json
```