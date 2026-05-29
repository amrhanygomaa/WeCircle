const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src';

const fixFile = (filePath) => {
    let content = fs.readFileSync(filePath, 'utf8');
    // Replace empty parameters with correct ones
    // We know file is always 'file'
    // And path varies.
    // Let's just fix it manually since there's only 5 instances.
    
    if (filePath.includes('exams/page.tsx')) {
        content = content.replace(/await uploadToS3\(, \);/g, 'await uploadToS3(file, filePath);');
    } else if (filePath.includes('settings/page.tsx')) {
        content = content.replace(/await uploadToS3\(, \);/g, 'await uploadToS3(file, path);');
    } else if (filePath.includes('DriverWizard.tsx') || filePath.includes('SupervisorWizard.tsx') || filePath.includes('TeacherWizard.tsx')) {
        content = content.replace(/await uploadToS3\(, \);/g, 'await uploadToS3(file, filePath);');
    }
    
    fs.writeFileSync(filePath, content, 'utf8');
};

const files = [
  'modules/dashboard/components/DriverWizard.tsx',
  'modules/dashboard/components/SupervisorWizard.tsx',
  'modules/dashboard/components/TeacherWizard.tsx',
  'app/dashboard/exams/page.tsx',
  'app/dashboard/settings/page.tsx'
];

files.forEach(f => fixFile(path.join(dir, f)));

console.log('Fixed uploadToS3 args');
