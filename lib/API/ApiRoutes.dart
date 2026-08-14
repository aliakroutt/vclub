class ApiRoutes {
  ApiRoutes._();
static const String upload_logo = "/upload/logo";
  /// Base URL
  static const String baseUrl = 'https://api-staging.vclub.fr/api';

  //Sign up merchant
  static const String register_merchant = '/auth/signup';
  //Sign in
  static const String Login = '/auth/login';
  // refresh token
  static const String refreshToken = '/auth/refresh'; 
  static const String change_password = '/auth/change-password' ;
  //merchant confirm payement  
   static const String confirm_payment = '/stripe/confirm-payment';
  // client
  static const String client_me = '/clients/me';
  static const String client_signup = '/clients/register';
  static const String verify_otp = '/clients/verify';
  static const String resend_otp = '/clients/resend-verification';
  // client dashboard
  static const String client_stats = '/memberships/history/stats';
  static const String client_history = '/memberships/history';
  static const String client_cards = '/memberships/mine';
  static const String client_rewards = '/client/rewards/redeemed/mine';
  static const String client_wheel_history = '/wheel/history';
  static String clientCardQr(String cardId) => '/memberships/card/$cardId/qr';
  static const String client_notifications = '/notifications/mine';
  static String clientReadNotif(String notifId) =>
      '/notifications/$notifId/read';
  static const String client_notifications_readall = '/notifications/read-all';
  static const String client_review_reward = '/reviews/';
  static String joinProgram(String clubSlug, String programSlug) =>
      '/clubs/$clubSlug/programs/$programSlug/join';
  static String GetPrograms(String clubSlug) => '/clubs/$clubSlug'; 
  static const String client_clubs = '/memberships/mine';

  // merchane
  static const String merchant_me = '/users/me';
  static const String merchant_stats = '/merchant/dashboard';
  static const String merchant_clients = '/merchant/clients';
  static const String merchant_rewards = '/rewards';
  static const String merchant_programs = '/loyalty/programs'; 
  static const String merchant_reddem_by_code = '/clients/by-code/';
  static const String merchant_loyalty_programs = "/loyalty/programs";
  static const String clients_by_code = "/clients/by-code";
static const String scan_points = "/scan/points"; 
static const String scan_redeem = "/scan/validate-code"; 
static const String program_clients_stats = "/merchant/clients/program/";
static const String program_clients = "/merchant/clients"; 
static const String merchant_agents = "/users/agents"; 

static const String merchant_wheel = "/wheel/config"; 
static const String merchant_wheel_history = "/wheel/merchant/wheel-spins"; 
static const String merchant_compaigns = "/campaigns";  
static const String merchant_notifications_send = "/notifications/sent";  
static const String merchant_notifications_compose = "/notifications/send"; 
static const String merchant_activity = "/merchant/activity"; 
static const String merchant_redemptions = "/merchant/redemptions"; 
static const String merchant_audit = "/merchant/audit"; 
static const String merchant_SMS = "/stripe/addons/sms";
static const String merchant_update_SMS = "/stripe/sms-addon"; 
static const String merchant_reactivate = "/stripe/resume-subscription"; 
static const String merchant_cancel_plan = "/stripe/cancel-subscription"; 
static const String merchant_plans = "/stripe/plans/public";
static const String merchant_change_plan = "/stripe/change-plan";
static const String merchant_invoices_history = "/transactions/my-company"; 
static const String merchant_portal = "/stripe/portal"; 
static const String merchant_resubscribe = "/stripe/resubscribe"; 
static const String merchant_loyalty_program = "/loyalty/program";
static const String merchant_rewards_list= "/rewards"; 
static const String merchant_my_company= "/companies/my-company";  
static const String merchant_sessions= "/auth/sessions";
static const String merchant_notifications = '/merchant/notifications/mine';
static String merchantReadNotif(String notifId) =>
    '/merchant/notifications/$notifId/read';
static const String merchant_notifications_readall = '/merchant/notifications/read-all';

}
