const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src';

const fixFile = (filePath) => {
    if (!fs.existsSync(filePath)) return;
    let content = fs.readFileSync(filePath, 'utf8');
    
    content = content.replace(/const error = null;/g, 'const error: any = null;');
    content = content.replace(/const uploadError = null;/g, 'const uploadError: any = null;');
    content = content.replace(/const updateError = null;/g, 'const updateError: any = null;');
    content = content.replace(/const signInErr = null;/g, 'const signInErr: any = null;');
    content = content.replace(/const updateErr = null;/g, 'const updateErr: any = null;');
    
    fs.writeFileSync(filePath, content, 'utf8');
};

const files = [
  'modules/dashboard/components/TeacherWizard.tsx',
  'modules/dashboard/components/SupervisorWizard.tsx',
  'modules/dashboard/components/DriverWizard.tsx',
  'app/update-password/page.tsx',
  'app/dashboard/settings/page.tsx',
  'app/dashboard/layout.tsx'
];

files.forEach(f => fixFile(path.join(dir, f)));

console.log('Fixed TS errors by typing null as any');
