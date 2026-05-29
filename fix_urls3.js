const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src';

const fixUrl = (filePath) => {
    let content = fs.readFileSync(filePath, 'utf8');
    content = content.replace(/const publicUrl = https:\/\/wecircle-storage-1779996505705\.s3\.us-east-1\.amazonaws\.com\/;/g, 'const publicUrl = `https://wecircle-storage-1779996505705.s3.us-east-1.amazonaws.com/${filePath}`;');
    fs.writeFileSync(filePath, content, 'utf8');
};

['app/dashboard/exams/page.tsx', 
 'modules/dashboard/components/DriverWizard.tsx', 
 'modules/dashboard/components/SupervisorWizard.tsx', 
 'modules/dashboard/components/TeacherWizard.tsx'].forEach(f => fixUrl(path.join(dir, f)));

// Fix AdmissionWizard
const admFile = path.join(dir, 'modules/dashboard/components/AdmissionWizard.tsx');
let admContent = fs.readFileSync(admFile, 'utf8');
admContent = admContent.replace(/const urlData = \{ publicUrl: https:\/\/wecircle-storage-1779996505705\.s3\.us-east-1\.amazonaws\.com\/ \};/g, 'const urlData = { publicUrl: `https://wecircle-storage-1779996505705.s3.us-east-1.amazonaws.com/${data.path}` };');
fs.writeFileSync(admFile, admContent, 'utf8');

console.log('Fixed URLs');
