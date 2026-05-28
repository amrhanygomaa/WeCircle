<div align="center">

# 🔵 WeCircle

### منصة متكاملة لإدارة الحضور والمواصلات المدرسية

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-Express-green?logo=node.js&logoColor=white)](https://nodejs.org)
[![Next.js](https://img.shields.io/badge/Next.js-16-black?logo=next.js&logoColor=white)](https://nextjs.org)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase&logoColor=white)](https://supabase.io)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Prisma](https://img.shields.io/badge/Prisma-ORM-2D3748?logo=prisma&logoColor=white)](https://prisma.io)

</div>

---

## 📋 نظرة عامة

**WeCircle** هي منصة شاملة لإدارة الحضور والمواصلات المدرسية، تربط بين أولياء الأمور والطلاب والمعلمين وسائقي الحافلات في بيئة موحدة ومتكاملة.

### المميزات الرئيسية

- 📱 **تطبيق موبايل** — Flutter للأندرويد والـ iOS يخدم 4 أدوار مختلفة
- 🖥️ **لوحة تحكم ويب** — Next.js للإدارة والمشرفين
- 🔒 **مصادقة آمنة** — JWT + Supabase Auth
- 🔔 **إشعارات فورية** — Socket.IO للتحديثات اللحظية
- 🗺️ **تتبع الحافلة** — مراقبة حية لمواقع الحافلات
- 📊 **تقارير ذكية** — إحصائيات الحضور وتحليل البيانات
- 🤖 **مساعد ذكاء اصطناعي** — مدعوم بـ Google Gemini

---

## 🏗️ هيكل المشروع

```
WeCircle/
├── 📱 mobile/              # تطبيق Flutter للموبايل
│   ├── lib/
│   │   ├── animations/     # الرسوم المتحركة
│   │   ├── core/           # الألوان والأنماط الأساسية
│   │   ├── models/         # نماذج البيانات
│   │   ├── screens/        # شاشات التطبيق
│   │   │   ├── driver/     # شاشات السائق
│   │   │   ├── parent/     # شاشات ولي الأمر
│   │   │   ├── student1-3/ # شاشات طلاب المرحلة الابتدائية
│   │   │   ├── student4-6/ # شاشات طلاب المرحلة الإعدادية
│   │   │   ├── student_shared/ # شاشات مشتركة للطلاب
│   │   │   └── teacher/    # شاشات المعلم
│   │   ├── services/       # خدمات API
│   │   ├── widgets/        # مكونات واجهة قابلة للإعادة
│   │   ├── app_theme.dart  # سمة التطبيق
│   │   ├── main.dart       # نقطة الدخول
│   │   └── state_manager.dart # إدارة الحالة
│   ├── assets/
│   │   ├── animations/     # ملفات Lottie
│   │   └── images/         # صور التطبيق
│   └── pubspec.yaml
│
├── 🖥️ dashboard/
│   ├── backend/            # خادم Node.js/Express
│   │   ├── prisma/
│   │   │   └── schema.prisma  # مخطط قاعدة البيانات
│   │   ├── src/
│   │   │   ├── config/     # إعدادات التطبيق
│   │   │   ├── controllers/ # متحكمات المسارات
│   │   │   ├── cron/       # المهام المجدولة
│   │   │   ├── middlewares/ # البرمجيات الوسيطة
│   │   │   ├── routes/     # تعريف المسارات
│   │   │   ├── services/   # منطق الأعمال
│   │   │   ├── types/      # تعريفات TypeScript
│   │   │   ├── utils/      # الأدوات المساعدة
│   │   │   └── server.ts   # نقطة دخول الخادم
│   │   ├── package.json
│   │   └── .env.example
│   │
│   └── frontend/           # لوحة التحكم Next.js
│       ├── src/
│       │   ├── app/        # صفحات Next.js App Router
│       │   ├── components/ # مكونات React
│       │   ├── lib/        # مكتبات مساعدة
│       │   └── types/      # تعريفات TypeScript
│       ├── package.json
│       └── .env.example
│
├── .gitignore
└── README.md
```

---

## 🚀 البدء السريع

### المتطلبات المسبقة

| الأداة | الإصدار |
|--------|---------|
| Flutter | ≥ 3.x |
| Node.js | ≥ 18.x |
| npm | ≥ 9.x |
| Git | ≥ 2.x |

### 1. استنساخ المشروع

```bash
git clone https://github.com/amrhanygomaa/WeCircle.git
cd WeCircle
```

### 2. إعداد الـ Backend

```bash
cd dashboard/backend

# نسخ ملف البيئة
cp .env.example .env
# ✏️ عدّل .env وأضف بيانات Supabase الخاصة بك

# تثبيت الحزم
npm install

# توليد Prisma Client
npm run prisma:generate

# تشغيل الخادم
npm run dev
# الخادم يعمل على: http://localhost:5001
```

### 3. إعداد الـ Frontend

```bash
cd dashboard/frontend

# نسخ ملف البيئة
cp .env.example .env
# ✏️ عدّل .env وأضف بيانات Supabase الخاصة بك

# تثبيت الحزم
npm install

# تشغيل الخادم
npm run dev
# التطبيق يعمل على: http://localhost:3000
```

### 4. إعداد تطبيق الموبايل

```bash
cd mobile

# تثبيت الحزم
flutter pub get

# تشغيل التطبيق
flutter run
```

---

## ⚙️ متغيرات البيئة

### Backend (`dashboard/backend/.env`)

```env
PORT=5001
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
DATABASE_URL=your_supabase_postgres_connection_string
```

### Frontend (`dashboard/frontend/.env`)

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_API_URL=http://localhost:5001/api
```

---

## 👥 أدوار المستخدمين

| الدور | الوصف |
|-------|-------|
| 👨‍👩‍👧 **ولي الأمر** | متابعة الطفل، تتبع الحافلة، الإشعارات |
| 🎓 **الطالب** | عرض الجدول، الحضور، الإشعارات |
| 🚌 **السائق** | إدارة الرحلات، الحضور، التنبيهات |
| 👩‍🏫 **المعلم** | تسجيل الحضور، التقارير، التواصل |

---

## 🛠️ التقنيات المستخدمة

### تطبيق الموبايل (Flutter)
- **Firebase** — Firestore لقاعدة البيانات
- **Lottie** — الرسوم المتحركة
- **Flutter ScreenUtil** — تصميم متجاوب
- **Flutter Animate** — تحريك واجهة المستخدم
- **PDF & Printing** — تصدير التقارير

### الخادم (Node.js)
- **Express.js** — إطار الويب
- **Prisma** — ORM لقاعدة البيانات
- **Supabase** — قاعدة البيانات والمصادقة
- **Socket.IO** — الاتصال اللحظي
- **Google Gemini AI** — مساعد ذكاء اصطناعي
- **JWT** — المصادقة والتفويض
- **Zod** — التحقق من البيانات

### لوحة التحكم (Next.js)
- **React 19** — واجهة المستخدم
- **TanStack Query** — إدارة حالة الخادم
- **Recharts** — الرسوم البيانية
- **Framer Motion** — الرسوم المتحركة
- **Tailwind CSS** — التنسيق
- **React Hook Form + Zod** — النماذج والتحقق

---

## 📄 الترخيص

هذا المشروع مخصص للأغراض الأكاديمية وتعليمية.

---

<div align="center">
Made with ❤️ by the WeCircle Team
</div>
