const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src';

const fixFile = (filePath) => {
    let content = fs.readFileSync(filePath, 'utf8');
    // Regex to match wait uploadToS3(file, <anything>, file.type)
    content = content.replace(/await uploadToS3\(([^,]+),\s*([^,]+),\s*[^)]+\);/g, 'await uploadToS3(, );');
    fs.writeFileSync(filePath, content, 'utf8');
};

const files = [
  'modules/dashboard/components/AdmissionWizard.tsx',
  'modules/dashboard/components/DriverWizard.tsx',
  'modules/dashboard/components/SupervisorWizard.tsx',
  'modules/dashboard/components/TeacherWizard.tsx',
  'app/dashboard/exams/page.tsx',
  'app/dashboard/settings/page.tsx'
];

files.forEach(f => fixFile(path.join(dir, f)));

console.log('Fixed uploadToS3 args');
