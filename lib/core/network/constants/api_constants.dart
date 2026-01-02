class ApiConstants {
  /// [Base Configuration]
  // static const String baseDomain = 'https://karlfive223-backend.onrender.com';
  static const String baseDomain = 'http://10.10.5.59:8001';
  // static const String baseDomain = 'http://localhost:8001';

  static const String baseUrl = '$baseDomain';

  /// [Headers]
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
    // Content-Type will be set automatically for multipart
  };

  /// [Endpoint Groups]
  static AuthEndpoints get auth => AuthEndpoints();
  static UserEndpoints get user => UserEndpoints();
  static ContactEndpoints get contact => ContactEndpoints();
  static NotificationEndpoints get notification => NotificationEndpoints();
  static ReportEndpoints get report => ReportEndpoints();

  //  ADD THIS
  static BrickEndpoints get bricks => BrickEndpoints();

  //  ADD THIS
  static EventEndpoints get events => EventEndpoints();
  static EventTodoEndpoints get eventTodos => EventTodoEndpoints();
  static TodoCategoryEndpoints get todoCategories => TodoCategoryEndpoints();
  static TodoItemEndpoints get todoItems => TodoItemEndpoints();

  static get team => null;

  static get league => null;
}

/// [Authentication Endpoints]
class AuthEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/auth';

  final String login = '$_base/login';
  final String register = '$_base/register';
  final String resetPass = '$_base/forget';
  final String refreshToken = '$_base/refresh-token';
  final String otpVerify = '$_base/verify-reset-otp';
  final String otpVerifyRegister = '$_base/verify';
  final String setNewPass = '$_base/reset-password';
  final String verifyEmail = '$_base/verify-email';
}

/// NEW: Events endpoints
class EventEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/events';

  /// POST /events
  final String create = _base;

  /// GET /events?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
  final String list = _base;

  /// Optional: GET /events/:id etc (if backend supports)
  String byId(String id) => '$_base/$id';
}

/// NEW: Event Todos endpoints
class EventTodoEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/event-todos';

  /// POST /event-todos
  final String create = _base;

  /// GET /event-todos/event/:eventId
  String listByEvent(String eventId) => '$_base/event/$eventId';
}



///  NEW: Brick endpoints (matches your Postman collection)
class BrickEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/bricks';

  /// POST /bricks  – create brick
  /// GET  /bricks  – list bricks
  final String base = _base;

  /// GET /bricks/:id
  /// PATCH /bricks/:id
  /// DELETE /bricks/:id
  String byId(String id) => '$_base/$id';
}

class UserEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/user';
  final String updateProfile = '$_base/update-profile';
  final String getUserProfile = '$_base/profile';

  // final String create = '$_base/create';
}

class NotificationEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/notification';

  final String getnotifications = '$_base/getnotifications';
}

class ContactEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/contact';
  final String createContact = '$_base/create';
}

class ReportEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/report';

  /// Create a report (POST)
  final String createReport = '$_base/create';

  /// Optional — in case backend supports fetching user reports later
  final String getReports = '$_base/all';
}
/// TODO Categories endpoints
class TodoCategoryEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/todo-categories';

  /// GET /todo-categories - Fetch all categories
  final String getAllCategories = _base;

  /// POST /todo-categories - Create a new category
  final String createCategory = _base;

  /// GET /todo-categories/:id
  String byId(String id) => '$_base/$id';

  /// PATCH /todo-categories/:id
  String updateCategory(String id) => '$_base/$id';

  /// DELETE /todo-categories/:id
  String deleteCategory(String id) => '$_base/$id';
}

/// TODO Items endpoints
class TodoItemEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/todo-items';

  /// POST /todo-items - Create a new todo item
  final String createTodoItem = _base;

  /// GET /todo-items/:id
  String byId(String id) => '$_base/$id';

  /// PATCH /todo-items/:id
  String updateTodoItem(String id) => '$_base/$id';

  /// DELETE /todo-items/:id
  String deleteTodoItem(String id) => '$_base/$id';

  /// GET /todo-items/category/:categoryId
  String byCategory(String categoryId) => '$_base/category/$categoryId';
}