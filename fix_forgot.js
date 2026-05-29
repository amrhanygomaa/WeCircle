const fs = require('fs');
const path = 'C:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app/forgot-password/page.tsx';
let content = fs.readFileSync(path, 'utf8');

// Replace all t('something') with t('something' as any)
// EXCEPT where it already has 'as any'
content = content.replace(/t\('([^']+)'\)/g, "t('' as any)");

fs.writeFileSync(path, content, 'utf8');
console.log('Fixed t() in forgot-password');
