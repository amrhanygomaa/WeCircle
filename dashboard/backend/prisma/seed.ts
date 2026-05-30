import {
  PrismaClient,
  Role,
  Gender,
  FeeType,
  InvoiceStatus,
  PaymentMethod,
  PaymentStatus,
  AttendanceStatus,
  AttendanceType,
  HomeworkStatus,
  ExamType,
  BehaviorType,
  BusAttendanceStatus,
} from '@prisma/client';
import * as crypto from 'crypto';

const prisma = new PrismaClient();

const hashPw = (pw: string) => crypto.createHash('sha256').update(pw).digest('hex');
const DEMO_PW = 'demo1234';
const DEMO_HASH = hashPw(DEMO_PW);

function daysAgo(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(8, 0, 0, 0);
  return d;
}

function daysFromNow(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() + n);
  d.setHours(8, 0, 0, 0);
  return d;
}

async function main() {
  console.log('🌱  Seeding WeCircle demo data...\n');

  // ── 1. School ─────────────────────────────────────────────────────
  const school = await prisma.school.create({
    data: {
      code: 'DEMO_001',
      name: 'مدارس النور الدولية',
      email: 'info@alnoor.edu.eg',
      phone: '+20 100 555 0001',
      address: 'القاهرة الجديدة، القاهرة',
      principalName: 'د. أحمد السيد',
      website: 'https://alnoor.edu.eg',
    },
  });

  await prisma.schoolSettings.create({
    data: {
      schoolId: school.id,
      language: 'ar',
      currency: 'EGP',
      timezone: 'Africa/Cairo',
      attendanceMode: 'DAILY',
      workingDays: [0, 1, 2, 3, 4],
      periodsPerDay: 7,
    },
  });

  // ── 2. Academic Year ──────────────────────────────────────────────
  const academicYear = await prisma.academicYear.create({
    data: {
      name: '2025-2026',
      startDate: new Date('2025-09-15'),
      endDate: new Date('2026-06-30'),
      isCurrent: true,
      schoolId: school.id,
    },
  });

  // ── 3. Grades ─────────────────────────────────────────────────────
  const [g1, g2, g3, g4, g5, g6] = await Promise.all([
    prisma.grade.create({ data: { name: 'الصف الأول',  nameEn: 'Grade 1', order: 1, schoolId: school.id } }),
    prisma.grade.create({ data: { name: 'الصف الثاني', nameEn: 'Grade 2', order: 2, schoolId: school.id } }),
    prisma.grade.create({ data: { name: 'الصف الثالث', nameEn: 'Grade 3', order: 3, schoolId: school.id } }),
    prisma.grade.create({ data: { name: 'الصف الرابع', nameEn: 'Grade 4', order: 4, schoolId: school.id } }),
    prisma.grade.create({ data: { name: 'الصف الخامس', nameEn: 'Grade 5', order: 5, schoolId: school.id } }),
    prisma.grade.create({ data: { name: 'الصف السادس', nameEn: 'Grade 6', order: 6, schoolId: school.id } }),
  ]);

  // ── 4. Classes ────────────────────────────────────────────────────
  const [c1a, c1b, c2a, c3a, c4a, c5a, c6a] = await Promise.all([
    prisma.schoolClass.create({ data: { name: '1/أ', section: 'أ', schoolId: school.id, gradeId: g1.id, academicYearId: academicYear.id } }),
    prisma.schoolClass.create({ data: { name: '1/ب', section: 'ب', schoolId: school.id, gradeId: g1.id, academicYearId: academicYear.id } }),
    prisma.schoolClass.create({ data: { name: '2/أ', section: 'أ', schoolId: school.id, gradeId: g2.id, academicYearId: academicYear.id } }),
    prisma.schoolClass.create({ data: { name: '3/أ', section: 'أ', schoolId: school.id, gradeId: g3.id, academicYearId: academicYear.id } }),
    prisma.schoolClass.create({ data: { name: '4/أ', section: 'أ', schoolId: school.id, gradeId: g4.id, academicYearId: academicYear.id } }),
    prisma.schoolClass.create({ data: { name: '5/أ', section: 'أ', schoolId: school.id, gradeId: g5.id, academicYearId: academicYear.id } }),
    prisma.schoolClass.create({ data: { name: '6/أ', section: 'أ', schoolId: school.id, gradeId: g6.id, academicYearId: academicYear.id } }),
  ]);

  // ── 5. Subjects ───────────────────────────────────────────────────
  const [arabic, math, science, social, english, religion, computers] = await Promise.all([
    prisma.subject.create({ data: { name: 'اللغة العربية',     code: 'ARB', schoolId: school.id, maxScore: 100, passScore: 50 } }),
    prisma.subject.create({ data: { name: 'الرياضيات',         code: 'MTH', schoolId: school.id, maxScore: 100, passScore: 50 } }),
    prisma.subject.create({ data: { name: 'العلوم',            code: 'SCI', schoolId: school.id, maxScore: 100, passScore: 50 } }),
    prisma.subject.create({ data: { name: 'الدراسات الاجتماعية', code: 'SOC', schoolId: school.id, maxScore: 100, passScore: 50 } }),
    prisma.subject.create({ data: { name: 'اللغة الإنجليزية', code: 'ENG', schoolId: school.id, maxScore: 100, passScore: 50 } }),
    prisma.subject.create({ data: { name: 'التربية الدينية',  code: 'REL', schoolId: school.id, maxScore: 100, passScore: 50 } }),
    prisma.subject.create({ data: { name: 'الحاسب الآلي',     code: 'CMP', schoolId: school.id, maxScore: 100, passScore: 50 } }),
  ]);

  // ── 6. School Admin (dashboard login via Cognito — no AppCredential) ──
  await prisma.user.create({
    data: {
      email: 'admin@alnoor.edu.eg',
      fullName: 'مدير النظام',
      role: Role.SCHOOL_ADMIN,
      schoolId: school.id,
    },
  });

  // ── 7. Teachers ───────────────────────────────────────────────────
  type TeacherRecord = { user: { id: string }; teacher: { id: string } };
  const teacherDefs = [
    { email: 'teacher1@alnoor.edu.eg', fullName: 'أستاذ محمود عبد الرحمن', loginId: 'TCH001', nameAr: 'محمود عبد الرحمن', phone: '+20 100 555 1001', spec: 'رياضيات' },
    { email: 'teacher2@alnoor.edu.eg', fullName: 'أستاذة سمر يوسف',        loginId: 'TCH002', nameAr: 'سمر يوسف',        phone: '+20 100 555 1002', spec: 'لغة عربية' },
    { email: 'teacher3@alnoor.edu.eg', fullName: 'أستاذ كريم منصور',       loginId: 'TCH003', nameAr: 'كريم منصور',       phone: '+20 100 555 1003', spec: 'علوم' },
  ];

  const teachers: TeacherRecord[] = [];
  for (const td of teacherDefs) {
    const tUser = await prisma.user.create({
      data: { email: td.email, fullName: td.fullName, role: Role.TEACHER, schoolId: school.id },
    });
    const teacher = await prisma.teacher.create({
      data: {
        userId: tUser.id,
        schoolId: school.id,
        nameAr: td.nameAr,
        phone: td.phone,
        specialization: td.spec,
        jobTitle: 'مدرس',
        stage: 'ابتدائي',
        salary: 8000,
        contractType: 'FULL_TIME',
        status: 'ACTIVE',
      },
    });
    await prisma.appCredential.create({
      data: {
        loginId: td.loginId,
        loginEmail: td.email,
        passwordHash: DEMO_HASH,
        plainTextPw: DEMO_PW,
        role: Role.TEACHER,
        schoolId: school.id,
        teacherId: teacher.id,
        isActive: true,
      },
    });
    teachers.push({ user: tUser, teacher });
  }
  const [t1, t2, t3] = teachers;

  // Assign class supervisors
  await prisma.schoolClass.update({ where: { id: c5a.id }, data: { teacherId: t1.teacher.id } });
  await prisma.schoolClass.update({ where: { id: c3a.id }, data: { teacherId: t2.teacher.id } });

  // Teacher ↔ Subject assignments
  await Promise.all([
    prisma.teacherSubject.create({ data: { teacherId: t1.teacher.id, subjectId: math.id,    classId: c5a.id } }),
    prisma.teacherSubject.create({ data: { teacherId: t1.teacher.id, subjectId: math.id,    classId: c4a.id } }),
    prisma.teacherSubject.create({ data: { teacherId: t2.teacher.id, subjectId: arabic.id,  classId: c3a.id } }),
    prisma.teacherSubject.create({ data: { teacherId: t2.teacher.id, subjectId: arabic.id,  classId: c1a.id } }),
    prisma.teacherSubject.create({ data: { teacherId: t3.teacher.id, subjectId: science.id, classId: c5a.id } }),
    prisma.teacherSubject.create({ data: { teacherId: t3.teacher.id, subjectId: science.id, classId: c6a.id } }),
  ]);

  // ── 8. Parents ────────────────────────────────────────────────────
  type ParentRecord = { user: { id: string }; parent: { id: string } };
  const parentDefs = [
    { email: 'parent1@demo.com', fullName: 'محمد إبراهيم الشافعي', loginId: 'PAR001', nameAr: 'محمد إبراهيم', phone: '+20 100 555 2001', relationship: 'أب' },
    { email: 'parent2@demo.com', fullName: 'نهى حسين علي',          loginId: 'PAR002', nameAr: 'نهى حسين',    phone: '+20 100 555 2002', relationship: 'أم' },
    { email: 'parent3@demo.com', fullName: 'طارق عمر فاروق',        loginId: 'PAR003', nameAr: 'طارق عمر',    phone: '+20 100 555 2003', relationship: 'أب' },
  ];

  const parents: ParentRecord[] = [];
  for (const pd of parentDefs) {
    const pUser = await prisma.user.create({
      data: { email: pd.email, fullName: pd.fullName, role: Role.PARENT, schoolId: school.id },
    });
    const parent = await prisma.parent.create({
      data: { userId: pUser.id, schoolId: school.id, nameAr: pd.nameAr, phone: pd.phone, relationship: pd.relationship },
    });
    await prisma.appCredential.create({
      data: {
        loginId: pd.loginId,
        loginEmail: pd.email,
        passwordHash: DEMO_HASH,
        plainTextPw: DEMO_PW,
        role: Role.PARENT,
        schoolId: school.id,
        parentId: parent.id,
        isActive: true,
      },
    });
    parents.push({ user: pUser, parent });
  }
  const [p1, p2, p3] = parents;

  // ── 9. Students ───────────────────────────────────────────────────
  type StudentRecord = { user: { id: string }; student: { id: string; classId: string | null; gradeId: string | null; useBus: boolean } };

  const studentDefs = [
    // Grade 5 (order 5) → 4-6 dashboard
    { email: 'student1@demo.com', fullName: 'يوسف محمد إبراهيم', loginId: 'STU001', nameAr: 'يوسف محمد',  gender: Gender.MALE,   grade: g5, cls: c5a, parent: p1, rel: 'father', points: 120, dob: new Date('2015-03-10'), useBus: true  },
    { email: 'student2@demo.com', fullName: 'لمى محمد إبراهيم',  loginId: 'STU002', nameAr: 'لمى محمد',   gender: Gender.FEMALE, grade: g5, cls: c5a, parent: p1, rel: 'father', points: 95,  dob: new Date('2016-07-22'), useBus: true  },
    { email: 'student3@demo.com', fullName: 'زيد نهى حسين',      loginId: 'STU003', nameAr: 'زيد نهى',    gender: Gender.MALE,   grade: g4, cls: c4a, parent: p2, rel: 'mother', points: 80,  dob: new Date('2016-11-05'), useBus: false },
    // Grade 3 (order 3) → 1-3 dashboard
    { email: 'student4@demo.com', fullName: 'ريم نهى حسين',      loginId: 'STU004', nameAr: 'ريم نهى',    gender: Gender.FEMALE, grade: g3, cls: c3a, parent: p2, rel: 'mother', points: 110, dob: new Date('2017-04-18'), useBus: false },
    // Grade 6 (order 6) → 4-6 dashboard
    { email: 'student5@demo.com', fullName: 'آدم طارق عمر',      loginId: 'STU005', nameAr: 'آدم طارق',   gender: Gender.MALE,   grade: g6, cls: c6a, parent: p3, rel: 'father', points: 145, dob: new Date('2014-08-30'), useBus: true  },
    // Grade 1 (order 1) → 1-3 dashboard
    { email: 'student6@demo.com', fullName: 'مي طارق عمر',       loginId: 'STU006', nameAr: 'مي طارق',    gender: Gender.FEMALE, grade: g1, cls: c1a, parent: p3, rel: 'father', points: 60,  dob: new Date('2019-01-14'), useBus: false },
    { email: 'student7@demo.com', fullName: 'عمر طارق عمر',      loginId: 'STU007', nameAr: 'عمر طارق',   gender: Gender.MALE,   grade: g2, cls: c2a, parent: p3, rel: 'father', points: 75,  dob: new Date('2018-06-08'), useBus: true  },
  ];

  const students: StudentRecord[] = [];
  for (const sd of studentDefs) {
    const sUser = await prisma.user.create({
      data: { email: sd.email, fullName: sd.fullName, role: Role.STUDENT, schoolId: school.id },
    });
    const studentData: Parameters<typeof prisma.student.create>[0]['data'] = {
      userId: sUser.id,
      schoolId: school.id,
      classId: sd.cls.id,
      gradeId: sd.grade.id,
      academicYearId: academicYear.id,
      nameAr: sd.nameAr,
      gender: sd.gender,
      dob: sd.dob,
      nationality: 'مصري',
      useBus: sd.useBus,
      points: sd.points,
      status: 'ACTIVE',
    };
    if (sd.rel === 'father') studentData.fatherId = sd.parent.parent.id;
    else studentData.motherId = sd.parent.parent.id;

    const student = await prisma.student.create({ data: studentData });
    await prisma.appCredential.create({
      data: {
        loginId: sd.loginId,
        loginEmail: sd.email,
        passwordHash: DEMO_HASH,
        plainTextPw: DEMO_PW,
        role: Role.STUDENT,
        schoolId: school.id,
        studentId: student.id,
        isActive: true,
      },
    });
    students.push({ user: sUser, student });
  }

  // ── 10. Bus + Driver + Supervisor ─────────────────────────────────
  const bus = await prisma.bus.create({
    data: { schoolId: school.id, number: 'BUS-01', plateNumber: 'أ ب ج 1234', capacity: 30, model: 'Toyota Coaster', year: 2022, status: 'ACTIVE' },
  });

  const driverUser = await prisma.user.create({
    data: { email: 'driver1@alnoor.edu.eg', fullName: 'أحمد الشهاوي', role: Role.DRIVER, schoolId: school.id },
  });
  const driver = await prisma.driver.create({
    data: {
      userId: driverUser.id, schoolId: school.id, busId: bus.id,
      name: 'أحمد الشهاوي', nameAr: 'أحمد الشهاوي', phone: '+20 100 555 3001',
      licenseType: 'مهنية – درجة أولى', status: 'ACTIVE',
    },
  });
  await prisma.appCredential.create({
    data: {
      loginId: 'DRV001', loginEmail: 'driver1@alnoor.edu.eg',
      passwordHash: DEMO_HASH, plainTextPw: DEMO_PW,
      role: Role.DRIVER, schoolId: school.id, driverId: driver.id, isActive: true,
    },
  });

  const supUser = await prisma.user.create({
    data: { email: 'supervisor1@alnoor.edu.eg', fullName: 'فاطمة النمر', role: Role.BUS_SUPERVISOR, schoolId: school.id },
  });
  const supervisor = await prisma.busSupervisor.create({
    data: {
      userId: supUser.id, schoolId: school.id, busId: bus.id,
      name: 'فاطمة النمر', nameAr: 'فاطمة النمر', phone: '+20 100 555 3002',
      gender: Gender.FEMALE, status: 'ACTIVE',
    },
  });
  await prisma.appCredential.create({
    data: {
      loginId: 'SUP001', loginEmail: 'supervisor1@alnoor.edu.eg',
      passwordHash: DEMO_HASH, plainTextPw: DEMO_PW,
      role: Role.BUS_SUPERVISOR, schoolId: school.id, supervisorId: supervisor.id, isActive: true,
    },
  });

  const busRoute = await prisma.busRoute.create({
    data: {
      schoolId: school.id, busId: bus.id,
      name: 'خط الحي الخامس', pickupTime: '06:45', dropoffTime: '14:15',
      stops: [
        { name: 'ميدان النهضة',  order: 1, lat: 30.0731, lng: 31.3482 },
        { name: 'شارع الفلاح',   order: 2, lat: 30.0720, lng: 31.3455 },
        { name: 'مدارس النور',   order: 3, lat: 30.0695, lng: 31.3410 },
      ],
    },
  });

  const busStudents = students.filter(s => s.student.useBus);
  for (const bs of busStudents) {
    await prisma.studentBus.create({
      data: {
        studentId: bs.student.id, busId: bus.id, routeId: busRoute.id,
        pickupPoint: 'ميدان النهضة', dropoffPoint: 'ميدان النهضة',
        fees: 1500, active: true,
      },
    });
  }

  // ── 11. Fee Structures ────────────────────────────────────────────
  const feeStructureDefs = [
    { name: 'رسوم الدراسة – الصف الأول',  gradeId: g1.id, feeType: FeeType.TUITION,    amount: 14000 },
    { name: 'رسوم الدراسة – الصف الثاني', gradeId: g2.id, feeType: FeeType.TUITION,    amount: 15000 },
    { name: 'رسوم الدراسة – الصف الثالث', gradeId: g3.id, feeType: FeeType.TUITION,    amount: 16000 },
    { name: 'رسوم الدراسة – الصف الرابع', gradeId: g4.id, feeType: FeeType.TUITION,    amount: 18000 },
    { name: 'رسوم الدراسة – الصف الخامس', gradeId: g5.id, feeType: FeeType.TUITION,    amount: 20000 },
    { name: 'رسوم الدراسة – الصف السادس', gradeId: g6.id, feeType: FeeType.TUITION,    amount: 22000 },
    { name: 'رسوم الباص',                  gradeId: null,  feeType: FeeType.BUS,         amount: 6000  },
    { name: 'رسوم الأنشطة',                gradeId: null,  feeType: FeeType.ACTIVITIES,  amount: 2000  },
    { name: 'رسوم الكتب',                  gradeId: null,  feeType: FeeType.BOOKS,        amount: 1500  },
  ];
  for (const fs of feeStructureDefs) {
    await prisma.feeStructure.create({ data: { ...fs, schoolId: school.id, academicYearId: academicYear.id } });
  }

  // ── 12. Invoices + Payments ───────────────────────────────────────
  const invoiceDefs = [
    { s: students[0], amount: 20000, paid: 20000, status: InvoiceStatus.PAID,    due: daysFromNow(60) },
    { s: students[1], amount: 20000, paid: 10000, status: InvoiceStatus.PARTIAL, due: daysFromNow(30) },
    { s: students[2], amount: 18000, paid: 0,     status: InvoiceStatus.OVERDUE, due: daysAgo(30)     },
    { s: students[3], amount: 16000, paid: 16000, status: InvoiceStatus.PAID,    due: daysFromNow(60) },
    { s: students[4], amount: 22000, paid: 22000, status: InvoiceStatus.PAID,    due: daysFromNow(60) },
    { s: students[5], amount: 14000, paid: 0,     status: InvoiceStatus.UNPAID,  due: daysFromNow(20) },
    { s: students[6], amount: 15000, paid: 7500,  status: InvoiceStatus.PARTIAL, due: daysFromNow(15) },
  ];

  for (let i = 0; i < invoiceDefs.length; i++) {
    const inv = invoiceDefs[i];
    const invoice = await prisma.invoice.create({
      data: {
        invoiceNumber: `INV-2026-${String(i + 1).padStart(3, '0')}`,
        schoolId: school.id,
        studentId: inv.s.student.id,
        feeType: FeeType.TUITION,
        totalAmount: inv.amount,
        paid: inv.paid,
        remaining: inv.amount - inv.paid,
        discount: 0,
        status: inv.status,
        dueDate: inv.due,
        paymentPlan: 'FULL',
      },
    });
    if (inv.paid > 0) {
      await prisma.payment.create({
        data: {
          schoolId: school.id,
          studentId: inv.s.student.id,
          invoiceId: invoice.id,
          amount: inv.paid,
          feeType: FeeType.TUITION,
          paymentMethod: PaymentMethod.CASH,
          status: PaymentStatus.PAID,
          paidAt: daysAgo(10 + i * 3),
          receiptNumber: `RCP-${String(i + 1).padStart(4, '0')}`,
        },
      });
    }
  }

  // ── 13. Attendance (last 5 working days) ──────────────────────────
  for (const dayOffset of [5, 4, 3, 2, 1]) {
    const date = daysAgo(dayOffset);
    // Students
    for (const s of students) {
      const status = Math.random() > 0.1 ? AttendanceStatus.PRESENT : AttendanceStatus.ABSENT;
      await prisma.attendance.create({
        data: {
          schoolId: school.id,
          studentId: s.student.id,
          classId: s.student.classId,
          type: AttendanceType.STUDENT,
          status,
          date,
          timeIn: status === AttendanceStatus.PRESENT ? '07:45' : null,
        },
      });
    }
    // Teachers
    for (const t of teachers) {
      await prisma.attendance.create({
        data: {
          schoolId: school.id,
          teacherId: t.teacher.id,
          type: AttendanceType.TEACHER,
          status: AttendanceStatus.PRESENT,
          date,
          timeIn: '07:30',
          timeOut: '14:00',
        },
      });
    }
  }

  // Bus attendance (today)
  const todayDate = new Date();
  todayDate.setHours(0, 0, 0, 0);
  for (const bs of busStudents) {
    await prisma.busAttendance.create({
      data: {
        schoolId: school.id,
        studentId: bs.student.id,
        busId: bus.id,
        supervisorId: supervisor.id,
        date: todayDate,
        status: BusAttendanceStatus.BOARDED,
      },
    });
  }

  // ── 14. Homework ──────────────────────────────────────────────────
  const hw1 = await prisma.homework.create({
    data: {
      schoolId: school.id,
      classId: c5a.id,
      subjectId: math.id,
      teacherId: t1.teacher.id,
      title: 'تدريبات على الكسور',
      description: 'حل التمارين من 1 إلى 10 في الكتاب المدرسي صفحة 45',
      sentDate: daysAgo(3),
      dueDate: daysFromNow(2),
      maxScore: 10,
      status: HomeworkStatus.OPEN,
    },
  });

  await prisma.homework.create({
    data: {
      schoolId: school.id,
      classId: c3a.id,
      subjectId: arabic.id,
      teacherId: t2.teacher.id,
      title: 'تعبير عن الربيع',
      description: 'اكتب موضوع تعبير لا يقل عن 10 أسطر عن فصل الربيع',
      sentDate: daysAgo(5),
      dueDate: daysAgo(1),
      maxScore: 20,
      status: HomeworkStatus.CLOSED,
    },
  });

  // Submissions for grade-5 homework
  const grade5Students = students.filter(s => s.student.gradeId === g5.id);
  for (const s of grade5Students) {
    await prisma.homeworkSubmission.create({
      data: {
        homeworkId: hw1.id,
        studentId: s.student.id,
        submittedAt: daysAgo(1),
        score: 7 + Math.floor(Math.random() * 4), // 7–10
        teacherComment: 'عمل جيد، استمر في التحسن',
      },
    });
  }

  // ── 15. Exams + Results ───────────────────────────────────────────
  const exam1 = await prisma.exam.create({
    data: {
      schoolId: school.id,
      subjectId: math.id,
      gradeId: g5.id,
      classId: c5a.id,
      name: 'امتحان شهر أبريل – رياضيات',
      type: ExamType.MONTHLY,
      date: daysAgo(10),
      maxScore: 100,
      passScore: 50,
      locked: true,
    },
  });

  const exam2 = await prisma.exam.create({
    data: {
      schoolId: school.id,
      subjectId: science.id,
      gradeId: g5.id,
      classId: c5a.id,
      name: 'اختبار علوم – وحدة الطاقة',
      type: ExamType.QUIZ,
      date: daysAgo(7),
      maxScore: 20,
      passScore: 10,
      locked: true,
    },
  });

  for (const s of grade5Students) {
    await prisma.examResult.create({
      data: { examId: exam1.id, studentId: s.student.id, score: 65 + Math.floor(Math.random() * 30), approved: true },
    });
    await prisma.examResult.create({
      data: { examId: exam2.id, studentId: s.student.id, score: 12 + Math.floor(Math.random() * 8), approved: true },
    });
  }

  // ── 16. Timetable (class 5/أ, Sun–Tue) ───────────────────────────
  const ttEntries = [
    { day: 0, p: 1, sub: arabic.id,   tch: t2.teacher.id },
    { day: 0, p: 2, sub: math.id,     tch: t1.teacher.id },
    { day: 0, p: 3, sub: science.id,  tch: t3.teacher.id },
    { day: 0, p: 4, sub: english.id,  tch: null          },
    { day: 0, p: 5, sub: social.id,   tch: null          },
    { day: 1, p: 1, sub: math.id,     tch: t1.teacher.id },
    { day: 1, p: 2, sub: arabic.id,   tch: t2.teacher.id },
    { day: 1, p: 3, sub: computers.id,tch: null          },
    { day: 1, p: 4, sub: science.id,  tch: t3.teacher.id },
    { day: 1, p: 5, sub: religion.id, tch: null          },
    { day: 2, p: 1, sub: english.id,  tch: null          },
    { day: 2, p: 2, sub: math.id,     tch: t1.teacher.id },
    { day: 2, p: 3, sub: social.id,   tch: null          },
    { day: 2, p: 4, sub: arabic.id,   tch: t2.teacher.id },
    { day: 2, p: 5, sub: science.id,  tch: t3.teacher.id },
  ];
  for (const tt of ttEntries) {
    await prisma.timetable.create({
      data: {
        schoolId: school.id,
        classId: c5a.id,
        subjectId: tt.sub,
        teacherId: tt.tch,
        day: tt.day,
        periodNumber: tt.p,
        startTime: `0${7 + tt.p}:00`,
        endTime:   `0${7 + tt.p}:45`,
      },
    });
  }

  // ── 17. Announcements ─────────────────────────────────────────────
  await prisma.announcement.createMany({
    data: [
      {
        schoolId: school.id,
        title: 'إجازة نصف العام الدراسي',
        body: 'تُعلن إدارة المدرسة أن إجازة نصف العام ستبدأ يوم السبت 18 يناير حتى 28 يناير. تعود الدراسة الأربعاء 29 يناير.',
        audience: 'all',
        pinned: true,
        publishDate: daysAgo(2),
      },
      {
        schoolId: school.id,
        title: 'ورشة عمل لأولياء الأمور',
        body: 'تدعوكم إدارة المدرسة لحضور ورشة عمل حول "تحفيز أبنائنا على التعلم" يوم الخميس القادم الساعة 5 مساءً.',
        audience: 'all',
        pinned: false,
        publishDate: daysAgo(1),
        expiryDate: daysFromNow(14),
      },
      {
        schoolId: school.id,
        title: 'موعد امتحانات الفصل الثاني',
        body: 'تبدأ امتحانات الفصل الدراسي الثاني في 15 مايو. يُرجى مراجعة الجدول الكامل على المنصة.',
        audience: 'all',
        pinned: false,
        publishDate: daysAgo(4),
        expiryDate: daysFromNow(30),
      },
      {
        schoolId: school.id,
        title: 'يوم الرياضة المدرسية',
        body: 'سيُقام يوم الرياضة السنوي يوم الأربعاء القادم. يُطلب من الطلاب ارتداء الزي الرياضي.',
        audience: 'all',
        pinned: false,
        publishDate: daysAgo(1),
        expiryDate: daysFromNow(7),
      },
    ],
  });

  // ── 18. Notifications ─────────────────────────────────────────────
  await prisma.notification.createMany({
    data: [
      {
        schoolId: school.id,
        recipientId: p1.user.id,
        title: 'تنبيه غياب',
        message: 'تم تسجيل غياب يوسف محمد اليوم',
        type: 'ABSENCE',
        channel: 'SYSTEM',
      },
      {
        schoolId: school.id,
        recipientId: p2.user.id,
        title: 'رسوم دراسية مستحقة',
        message: 'تذكير: رسوم الفصل الثاني لزيد نهى متأخرة. يُرجى السداد في أقرب وقت.',
        type: 'FEE_DUE',
        channel: 'SYSTEM',
      },
      {
        schoolId: school.id,
        recipientId: p1.user.id,
        title: 'واجب جديد – رياضيات',
        message: 'أرسل أستاذ محمود واجباً جديداً: تدريبات على الكسور. موعد التسليم بعد يومين.',
        type: 'HOMEWORK',
        channel: 'SYSTEM',
      },
      {
        schoolId: school.id,
        recipientId: p3.user.id,
        title: 'نتيجة امتحان',
        message: 'حصل آدم طارق على 88/100 في امتحان شهر أبريل – رياضيات.',
        type: 'RESULT',
        channel: 'SYSTEM',
      },
    ],
  });

  // ── 19. Calendar Events ───────────────────────────────────────────
  const now = new Date();
  await prisma.calendarEvent.createMany({
    data: [
      {
        schoolId: school.id, title: 'اجتماع مجلس الأمناء',
        day: 15, month: now.getMonth() + 1, year: now.getFullYear(),
        startTime: '17:00', endTime: '19:00', type: 'MEETING',
      },
      {
        schoolId: school.id, title: 'يوم الرياضة المدرسية',
        day: 22, month: now.getMonth() + 1, year: now.getFullYear(),
        startTime: '09:00', endTime: '12:00', type: 'ACTIVITY',
      },
      {
        schoolId: school.id, title: 'امتحانات نهاية العام',
        day: 15, month: 5, year: 2026,
        startTime: '08:00', endTime: '12:00', type: 'EXAM',
      },
      {
        schoolId: school.id, title: 'اليوم المفتوح لأولياء الأمور',
        day: 8, month: now.getMonth() + 1, year: now.getFullYear(),
        startTime: '10:00', endTime: '13:00', type: 'MEETING',
      },
    ],
  });

  // ── 20. Behavior Reports ──────────────────────────────────────────
  await prisma.behaviorReport.create({
    data: {
      schoolId: school.id,
      teacherId: t1.teacher.id,
      studentId: students[0].student.id,
      classId: c5a.id,
      type: BehaviorType.POSITIVE,
      traits: 'مجتهد,متعاون,منتبه',
      notes: 'الطالب يتحسن بشكل ملحوظ ويشارك باستمرار في الحصة.',
    },
  });
  await prisma.behaviorReport.create({
    data: {
      schoolId: school.id,
      teacherId: t2.teacher.id,
      studentId: students[3].student.id,
      classId: c3a.id,
      type: BehaviorType.FOLLOWUP,
      traits: 'يحتاج متابعة,كثير الحركة',
      notes: 'الطالبة تشتت خلال الحصة، تحتاج متابعة منزلية.',
    },
  });
  await prisma.behaviorReport.create({
    data: {
      schoolId: school.id,
      teacherId: t1.teacher.id,
      studentId: students[1].student.id,
      classId: c5a.id,
      type: BehaviorType.POSITIVE,
      traits: 'دقيقة,منظمة',
      notes: 'تسلم واجباتها دائماً في الوقت المحدد.',
    },
  });

  // ── 21. Daily Reports ─────────────────────────────────────────────
  await prisma.dailyReport.create({
    data: {
      schoolId: school.id,
      teacherId: t1.teacher.id,
      classId: c5a.id,
      date: daysAgo(1),
      interactionLevel: 'عالي',
      attentionPercent: 85,
      participationPercent: 70,
      summary: 'حصة منتجة، الطلاب متفاعلون. تم شرح وحدة الكسور بالكامل.',
    },
  });
  await prisma.dailyReport.create({
    data: {
      schoolId: school.id,
      teacherId: t2.teacher.id,
      classId: c3a.id,
      date: daysAgo(2),
      interactionLevel: 'متوسط',
      attentionPercent: 72,
      participationPercent: 60,
      summary: 'قرأنا قصيدة "العلم" وناقشنا معانيها. بعض الطلاب يحتاجون مزيداً من التدريب.',
    },
  });

  // ── 22. Student Tasks ─────────────────────────────────────────────
  const task1 = await prisma.studentTask.create({
    data: {
      schoolId: school.id,
      teacherId: t1.teacher.id,
      classId: c5a.id,
      title: 'مسابقة الضرب السريع',
      description: 'أكمل جدول الضرب من 1 إلى 12 في أقل من دقيقتين',
      dueDate: daysFromNow(3),
      rewardPoints: 50,
    },
  });

  await prisma.studentTask.create({
    data: {
      schoolId: school.id,
      teacherId: t2.teacher.id,
      classId: c3a.id,
      title: 'تلاوة سورة الملك',
      description: 'احفظ وأتقن تلاوة سورة الملك كاملةً',
      dueDate: daysFromNow(7),
      rewardPoints: 100,
    },
  });

  await prisma.studentTaskCompletion.create({
    data: { taskId: task1.id, studentId: students[0].student.id },
  });

  // ── 23. Game Progress ─────────────────────────────────────────────
  for (const s of students.slice(0, 5)) {
    for (let gameId = 1; gameId <= 5; gameId++) {
      await prisma.studentGameProgress.create({
        data: {
          schoolId: school.id,
          studentId: s.student.id,
          gameId,
          level: 1 + Math.floor(Math.random() * 5),
          points: 50 + Math.floor(Math.random() * 200),
        },
      });
    }
  }

  // ── 24. Applications (Admissions) ────────────────────────────────
  await prisma.application.create({
    data: {
      schoolId: school.id,
      academicYearId: academicYear.id,
      gradeId: g1.id,
      childNameAr: 'سلمى نادر حسن',
      childNameEn: 'Salma Nader',
      childDob: new Date('2019-03-20'),
      childGender: Gender.FEMALE,
      status: 'UNDER_REVIEW',
      applicationType: 'NEW_ADMISSION',
    },
  });
  await prisma.application.create({
    data: {
      schoolId: school.id,
      academicYearId: academicYear.id,
      gradeId: g3.id,
      childNameAr: 'محمود سامي عبد الله',
      childDob: new Date('2017-09-01'),
      childGender: Gender.MALE,
      status: 'DOCUMENTS_INCOMPLETE',
      applicationType: 'TRANSFER',
      previousSchool: 'مدارس الأمل الدولية',
    },
  });
  await prisma.application.create({
    data: {
      schoolId: school.id,
      academicYearId: academicYear.id,
      gradeId: g2.id,
      childNameAr: 'هدى وائل إبراهيم',
      childDob: new Date('2018-05-15'),
      childGender: Gender.FEMALE,
      status: 'NEW',
      applicationType: 'NEW_ADMISSION',
    },
  });

  // ── Done ──────────────────────────────────────────────────────────
  console.log('\n✅  Demo data seeded successfully!\n');
  console.log('═══════════════════════════════════════════');
  console.log('  📱  Mobile App Logins  (password: demo1234)');
  console.log('───────────────────────────────────────────');
  console.log('  Teachers :  TCH001  TCH002  TCH003');
  console.log('  Parents  :  PAR001  PAR002  PAR003');
  console.log('  Students :  STU001  STU002  STU003  STU004');
  console.log('             STU005  STU006  STU007');
  console.log('  Driver   :  DRV001');
  console.log('  Supervisor: SUP001');
  console.log('───────────────────────────────────────────');
  console.log('  🌐  Dashboard Admin: admin@alnoor.edu.eg');
  console.log('      (authenticate via AWS Cognito)');
  console.log('═══════════════════════════════════════════\n');
}

main()
  .catch(e => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
