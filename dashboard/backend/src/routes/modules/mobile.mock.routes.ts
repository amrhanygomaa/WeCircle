import { Router } from "express";

const router = Router();

router.get("/children", (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: 'student_adham',
        name: 'أدهم',
        grade: 'الصف الخامس',
        image: 'https://i.pravatar.cc/150?u=adham',
        color: '#6366F1', // Hex instead of Flutter Color
        attendance: '98%',
        homeworkCount: '3',
        gpa: 'A-',
        statusMessage: 'أدهم في المدرسة حالياً',
        arrivalTime: '07:52 ص',
        teachers: ['مدرس العربي', 'مدرس الانجلش', 'مدرس الرياضة'],
      },
      {
        id: 'student_kareem',
        name: 'كريم',
        grade: 'الصف الثالث - ب',
        image: 'https://i.pravatar.cc/150?u=kareem',
        color: '#EC4899',
        attendance: '94%',
        homeworkCount: '1',
        gpa: 'B+',
        statusMessage: 'كريم غادر المدرسة الآن',
        arrivalTime: '08:10 ص',
        teachers: ['مدرس العلوم', 'مدرس العربي'],
      },
      {
        id: 'student_mariam',
        name: 'مريم',
        grade: 'التمهيدي - أ',
        image: 'https://i.pravatar.cc/150?u=mariam',
        color: '#10B981',
        attendance: '100%',
        homeworkCount: '0',
        gpa: 'A+',
        statusMessage: 'مريم في الفصل حالياً',
        arrivalTime: '07:45 ص',
        teachers: ['أستاذة رنا', 'أستاذة أمل'],
      },
    ]
  });
});

export default router;
