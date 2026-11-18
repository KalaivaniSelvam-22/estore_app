# E-Store – Flutter E-Commerce Application

E-Store is a Flutter-based e-commerce application with role-based access for Admin and Super Admin users. It includes product browsing, cart management, inventory handling, and product management.

## Features

### Admin
- Login using a user code and password.
- View products with images, prices, and stock availability.
- Search and filter products by name and category.
- View available products before out-of-stock products.
- Add products to the cart.
- Update quantities and manage cart items.
- Checkout is not currently implemented.

### Super Admin
- View the product dashboard.
- Add new products.
- Update existing product details.
- Delete products.
- Manage product stock quantities.
- Search and filter products.

### Other Features
- Role-based login.
- Session persistence with automatic expiry after 24 hours.
- Product image selection from the device.
- Loading and error states for product images.
- Stock-aware cart quantity controls.
- Responsive product listing.
- Logout confirmation.

## Tech Stack

- Flutter and Dart
- BLoC for state management
- Dio for API communication
- GetIt for dependency injection
- Equatable for state comparison
- SharedPreferences for local session and data storage
- Fake Store API for product data

## Demo Login Credentials

| Role | User Code | Password |
|---|---|---|
| Admin | `1001` | `admin` |
| Super Admin | `1002` | `superadmin` |

These are static demo credentials for testing the application. They are not intended for production authentication.

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical Android device

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/KalaivaniSelvam-22/estore_app.git
   ```

2. Open the project folder:

   ```bash
   cd estore_app
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

### Build APK

To generate a release APK:

```bash
flutter build apk --release
```

The APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Project Structure

```text
lib/
├── blocs/
│   ├── auth/
│   ├── cart/
│   └── product/
├── core/
│   ├── di/
│   └── errors/
├── models/
├── screens/
├── services/
└── widgets/

test/
assets/
```

## API and Data Storage Notes

This project uses the Fake Store API for product data.

- The Fake Store API is a demo API. Product creation, updates, and deletion are simulated and are not guaranteed to persist on the server.
- Stock quantities are maintained locally because the API does not provide inventory management.
- Product images selected from the device are stored in the application's local storage.
- Locally stored images and inventory changes are not automatically synchronized across devices.

## Testing

Run the test suite:

```bash
flutter test
```

Check the project for static analysis issues:

```bash
flutter analyze
```

## Future Improvements

- Backend integration with persistent database storage.
- Real authentication and authorization.
- Order placement and order history.
- Payment gateway integration.
- Cloud-based product image storage.
- Persistent inventory synchronization.

## Author

**Kalaivani Selvam**

GitHub: [KalaivaniSelvam-22](https://github.com/KalaivaniSelvam-22)

---

This project was developed as a Flutter e-commerce application to practise state management, API integration, role-based access, and product inventory workflows.