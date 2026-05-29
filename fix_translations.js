const fs = require('fs');
const path = require('path');

const i18nPath = path.join(__dirname, 'dashboard', 'frontend', 'src', 'core', 'i18n', 'i18n.ts');
let i18nContent = fs.readFileSync(i18nPath, 'utf8');

const enKeys = `
    auth_register_title: "Create your school account",
    auth_register_subtitle: "Begin Your Journey as an Authorized Institution.",
    field_name: "Full Name",
    field_email: "Email Address",
    field_phone: "Phone Number",
    field_password: "Password",
    field_confirm_password: "Confirm Password",
    auth_btn_loading: "Loading...",
    auth_btn_register: "Create Account",
    auth_have_account: "Already have Account?",
`;

const arKeys = `
    auth_register_title: "إنشاء حساب مدرسة جديد",
    auth_register_subtitle: "ابدأ رحلتك كمؤسسة معتمدة.",
    field_name: "الاسم الكامل",
    field_email: "البريد الإلكتروني",
    field_phone: "رقم الهاتف",
    field_password: "كلمة المرور",
    field_confirm_password: "تأكيد كلمة المرور",
    auth_btn_loading: "جاري التحميل...",
    auth_btn_register: "إنشاء الحساب",
    auth_have_account: "لديك حساب بالفعل؟",
`;

i18nContent = i18nContent.replace('en: {', 'en: {' + enKeys);
i18nContent = i18nContent.replace('ar: {', 'ar: {' + arKeys);

fs.writeFileSync(i18nPath, i18nContent, 'utf8');
console.log('Added missing keys to i18n.ts');
