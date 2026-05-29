const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src';

const fixUrl = (filePath) => {
    let content = fs.readFileSync(filePath, 'utf8');
    // Fix missing quotes around URL
    content = content.replace(/publicUrl: https:\/\/wecircle-storage-1779996505705\.s3\.us-east-1\.amazonaws\.com\/\$\{data\.path\}/g, 'publicUrl: `https://wecircle-storage-1779996505705.s3.us-east-1.amazonaws.com/${data.path}`');
    content = content.replace(/const publicUrl = https:\/\/wecircle-storage-1779996505705\.s3\.us-east-1\.amazonaws\.com\/\$\{filePath\};/g, 'const publicUrl = `https://wecircle-storage-1779996505705.s3.us-east-1.amazonaws.com/${filePath}`;');
    fs.writeFileSync(filePath, content, 'utf8');
};

['modules/dashboard/components/AdmissionWizard.tsx', 
 'app/dashboard/exams/page.tsx', 
 'modules/dashboard/components/DriverWizard.tsx', 
 'modules/dashboard/components/SupervisorWizard.tsx', 
 'modules/dashboard/components/TeacherWizard.tsx'].forEach(f => fixUrl(path.join(dir, f)));

// Fix settings/page.tsx
const settingsFile = path.join(dir, 'app/dashboard/settings/page.tsx');
let settingsContent = fs.readFileSync(settingsFile, 'utf8');
// The regex ate: `const { data } = supabase.storage.from(schoolBucket).getPublicUrl(path);` and what else?
// Let's just fix it. The bad line is:
// await uploadToS3(file, path, file.type); const uploadError = null; }); }
// Wait, I need to know the exact bad line to replace it.
settingsContent = settingsContent.replace(/await uploadToS3\(file, path, file\.type\); const uploadError = null; \}\); \}/g, 'await uploadToS3(file, path, file.type); const data = { publicUrl: `https://wecircle-storage-1779996505705.s3.us-east-1.amazonaws.com/${path}` };');
fs.writeFileSync(settingsFile, settingsContent, 'utf8');

console.log('Fixed URLs');
