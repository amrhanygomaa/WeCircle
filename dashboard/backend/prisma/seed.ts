import { PrismaClient, Role, Gender } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database with real initial data...');

  // 1. Create a School
  const school = await prisma.school.create({
    data: {
      code: 'WECIRCLE_001',
      name: 'مدارس وصال الدولية',
      email: 'info@wesal.edu',
      phone: '+20 100 123 4567',
    },
  });

  // 2. Create Grades & Classes
  const grade1 = await prisma.grade.create({ data: { name: 'الصف الخامس', order: 5, schoolId: school.id } });
  const grade2 = await prisma.grade.create({ data: { name: 'الصف الثالث', order: 3, schoolId: school.id } });
  const grade3 = await prisma.grade.create({ data: { name: 'التمهيدي', order: 0, schoolId: school.id } });

  const class1 = await prisma.schoolClass.create({ data: { name: '5/أ', section: 'أ', schoolId: school.id, gradeId: grade1.id } });
  const class2 = await prisma.schoolClass.create({ data: { name: '3/ب', section: 'ب', schoolId: school.id, gradeId: grade2.id } });
  const class3 = await prisma.schoolClass.create({ data: { name: 'KG/أ', section: 'أ', schoolId: school.id, gradeId: grade3.id } });

  // 3. Create a Parent
  const parentUser = await prisma.user.create({
    data: {
      email: 'parent@wecircle.com',
      fullName: 'سارة محمد',
      role: Role.PARENT,
      schoolId: school.id,
    },
  });

  const parent = await prisma.parent.create({
    data: {
      userId: parentUser.id,
      schoolId: school.id,
      phone: '+20 100 123 4567',
    },
  });

  // 4. Create Students (Children)
  const studentUsers = await Promise.all([
    prisma.user.create({ data: { email: 'adham@wecircle.com', fullName: 'أدهم', role: Role.STUDENT, schoolId: school.id } }),
    prisma.user.create({ data: { email: 'kareem@wecircle.com', fullName: 'كريم', role: Role.STUDENT, schoolId: school.id } }),
    prisma.user.create({ data: { email: 'mariam@wecircle.com', fullName: 'مريم', role: Role.STUDENT, schoolId: school.id } }),
  ]);

  await prisma.student.create({
    data: {
      userId: studentUsers[0].id,
      schoolId: school.id,
      classId: class1.id,
      gradeId: grade1.id,
      nameAr: 'أدهم',
      gender: Gender.MALE,
      motherId: parent.id,
      photo: 'https://i.pravatar.cc/150?u=adham',
      points: 98,
    },
  });

  await prisma.student.create({
    data: {
      userId: studentUsers[1].id,
      schoolId: school.id,
      classId: class2.id,
      gradeId: grade2.id,
      nameAr: 'كريم',
      gender: Gender.MALE,
      motherId: parent.id,
      photo: 'https://i.pravatar.cc/150?u=kareem',
      points: 94,
    },
  });

  await prisma.student.create({
    data: {
      userId: studentUsers[2].id,
      schoolId: school.id,
      classId: class3.id,
      gradeId: grade3.id,
      nameAr: 'مريم',
      gender: Gender.FEMALE,
      motherId: parent.id,
      photo: 'https://i.pravatar.cc/150?u=mariam',
      points: 100,
    },
  });

  console.log('Database seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
