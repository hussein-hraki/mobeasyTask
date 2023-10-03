//ملف الاحداث
abstract class AppEvents {}

//حدث تسجيل الدخول باستخدام جوجل
class SignGoogleEvent extends AppEvents {}

//حدث تحميل الأسئلة
class LoadingMathcEvent extends AppEvents {}

//حدث ارسال النتيجة واظهار لوحة المتصدرين
class SendAndShowBoardEvent extends AppEvents {}

//حدث تسجيل الخروج وإعادة التطبيق من البداية
class RestartEvent extends AppEvents {}
