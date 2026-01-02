# Todo Categories Implementation Guide

## 📋 Architecture Overview

This implementation follows the **Clean Architecture** pattern with **GetX** for state management:

```
Presentation Layer (UI)
    ↓
Controllers (GetX)
    ↓
Repositories (Abstract & Impl)
    ↓
Data Models & API Client
    ↓
Network Layer
```

## 🔧 Complete File Structure

```
lib/features/todos/
├── data/
│   ├── models/
│   │   ├── category_model.dart          [NEW] ✨
│   │   └── categories_response.dart     [NEW] ✨
│   └── repositories/
│       └── todo_category_repository_impl.dart [NEW] ✨
├── domain/
│   └── repositories/
│       └── todo_category_repository.dart [NEW] ✨
└── presentation/
    ├── controllers/
    │   └── event_totos_controller.dart  [UPDATED]
    ├── screens/
    │   └── event_todos_screen.dart      [Already uses controller]
    └── widgets/
        └── categories_grid.dart         [UPDATED] ✨

lib/core/
├── di/
│   ├── setup_repository.dart            [UPDATED]
│   └── set_controllers.dart             [UPDATED]
└── network/
    └── constants/
        └── api_constants.dart           [UPDATED]
```

## 🚀 How It Works

### 1️⃣ **API Request Flow**

```dart
// User opens EventTodosScreen
EventTodosScreen
  └─> GetView<EventTodosController>()
      └─> onInit() called automatically
          └─> fetchCategories()
              └─> _categoryRepository.getAllCategories()
                  └─> ApiClient.get<CategoriesResponse>()
                      └─> HTTP GET /todo-categories
                          └─> Response parsed → List<CategoryModel>
                              └─> categories.value = list (notifies UI)
```

### 2️⃣ **State Management**

```dart
// In EventTodosController
final categories = <CategoryModel>[].obs;      // Reactive list
final isLoading = false.obs;                   // Loading indicator
final errorMessage = ''.obs;                   // Error handling

// Any change to these observables triggers widget rebuild
```

### 3️⃣ **UI Updates (Reactive)**

```dart
// In CategoriesGrid
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  
  // Build grid from controller.categories
  // Automatically rebuilds when categories change
})
```

## 📦 Model Structure

### CategoryModel
Represents a single todo category from the API:

```dart
CategoryModel(
  id: "69564789153bb0af3a163a66",
  name: "Work",
  createdBy: "695243d8381b0354f35e7152",
  color: "#03A9F4",                    // Hex color from API
  participants: ["695243d8381b0354f35e7152"],
  createdAt: DateTime.parse("2026-01-01T10:08:09.574Z"),
  updatedAt: DateTime.parse("2026-01-01T10:08:09.574Z"),
)
```

### CategoriesResponse
Wraps the API response:

```dart
CategoriesResponse(
  success: true,
  message: "Todo categories retrieved successfully",
  data: [CategoryModel, CategoryModel, ...],
)
```

## 🎨 Color Handling

The API returns hex colors like `"#03A9F4"`, which are automatically converted to Flutter `Color` objects:

```dart
// From API: "#03A9F4"
Color color = _hexToColor("#03A9F4");
// Result: Color(0xFF03A9F4)
```

## 🔄 Dependency Injection (DI)

GetX lazily initializes dependencies when needed:

```dart
// In setup_repository.dart
Get.lazyPut<TodoCategoryRepository>(
  () => TodoCategoryRepositoryImpl(apiClient: Get.find()),
);

// In set_controllers.dart
Get.lazyPut<EventTodosController>(
  () => EventTodosController(categoryRepository: Get.find()),
);
```

When the controller is first accessed, all dependencies are automatically resolved.

## 🌐 API Endpoint Configuration

Endpoint is defined in `ApiConstants`:

```dart
class TodoCategoryEndpoints {
  final String getAllCategories = '/todo-categories';
  final String createCategory = '/todo-categories';
  // Plus CRUD methods for individual categories
}

// Access it:
ApiConstants.todoCategories.getAllCategories  // /todo-categories
```

Base URL from `ApiConstants.baseUrl` is automatically prepended.

## 📡 Error Handling

Multiple layers of error handling:

```dart
// Layer 1: API Client handles network errors
// Returns: Either<NetworkFailure, NetworkSuccess<Data>>

// Layer 2: Repository maps to business logic
// Returns: Either<NetworkFailure, NetworkSuccess<List<CategoryModel>>>

// Layer 3: Controller handles in fetchCategories()
result.fold(
  (failure) => errorMessage.value = failure.message,  // Failure path
  (success) => categories.value = success.data,       // Success path
);
```

## 🎯 Usage in Your App

### To use the categories:

```dart
// In any widget inside EventTodosScreen
GetBuilder<EventTodosController>(
  builder: (controller) {
    return ListView.builder(
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return CategoryCard(
          title: category.name,
          color: _hexToColor(category.color),
        );
      },
    );
  },
);

// Or use Obx for finer reactivity:
Obx(() => Text(controller.categories.length.toString()))
```

### To refresh categories manually:

```dart
ElevatedButton(
  onPressed: () => controller.refreshCategories(),
  child: Text('Refresh'),
)
```

## ✨ Special Features

### 1. Always Show "Add Category" Button
Even if there are zero categories, the "+" button is always visible.

### 2. Loading State
Shows a spinner while fetching from API.

### 3. Auto-Fetch on Screen Open
`onInit()` automatically fetches categories when the screen loads.

### 4. No Persistent Local Data
Categories are fetched fresh each time the screen opens. For offline support, add caching in the future.

## 🧪 Testing the Implementation

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Navigate to Todos screen** (EventTodosScreen)

3. **Observe**:
   - Loading spinner appears briefly
   - Categories appear in grid after API responds
   - Each category shows its name and color from API
   - "Add Category" button is always visible

4. **Tap on a category** to open its details dialog

5. **Tap "+" button** to create a new category (functionality to be implemented)

## 🔮 Future Enhancements

Add these features as needed:

```dart
// In EventTodosController:

// Create a new category
Future<void> createCategory(String name, String color) async {
  // Call API to create
  // Refresh list
}

// Delete a category
Future<void> deleteCategory(String categoryId) async {
  // Call API to delete
  // Remove from list
}

// Update a category
Future<void> updateCategory(String categoryId, ...) async {
  // Call API to update
  // Update in list
}

// Local caching
Future<void> _loadCachedCategories() async {
  // Load from Hive box
}

void _cacheCategories() async {
  // Save to Hive box
}
```

## 📝 API Request/Response Example

### Request
```
GET /todo-categories
Host: 10.10.5.59:8001
Authorization: Bearer {token}
Content-Type: application/json
```

### Response (200 OK)
```json
{
  "success": true,
  "message": "Todo categories retrieved successfully",
  "data": [
    {
      "_id": "69564789153bb0af3a163a66",
      "name": "Work",
      "createdBy": "695243d8381b0354f35e7152",
      "color": "#03A9F4",
      "participants": ["695243d8381b0354f35e7152"],
      "createdAt": "2026-01-01T10:08:09.574Z",
      "updatedAt": "2026-01-01T10:08:09.574Z",
      "__v": 0
    }
    // ... more categories
  ]
}
```

## 🎓 Key Concepts Used

- **GetX State Management**: Reactive variables and controllers
- **Repository Pattern**: Abstraction over data sources
- **Dependency Injection**: Loose coupling of components
- **Either Type**: Functional error handling (Success/Failure)
- **Equatable**: Value equality for models
- **Factory Constructors**: JSON serialization/deserialization
- **RxList/RxBool/RxString**: Observable types
- **Obx Widget**: Observes and rebuilds on observable changes

## 🚨 Important Notes

1. **Token Handling**: API client automatically adds Bearer token from secure storage
2. **Network Connectivity**: API client handles offline by serving cached data
3. **Type Safety**: All models are properly typed with null safety
4. **Memory Efficiency**: Lazy initialization means controllers only load when needed

---

For any questions or modifications, refer to the GetX documentation: https://pub.dev/packages/get
