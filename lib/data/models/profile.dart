class SessionManager { 
  static final SessionManager _instance = SessionManager._internal(); 
  factory SessionManager() => _instance; SessionManager._internal(); 
  String? sessionId; int? accountId; void clear() { 
    sessionId = null; 
    accountId = null; 
    } 
  }
