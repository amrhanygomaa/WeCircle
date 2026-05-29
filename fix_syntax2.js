const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app';

const fixFile = (filePath) => {
  if (!fs.existsSync(filePath)) return;
  let content = fs.readFileSync(filePath, 'utf8');
  // Match any className={ tn-glass-primary... } or \tn-glass-primary \}
  content = content.replace(/className=\{\s*tn-glass-primary\s*\\?\}/g, 'className="btn-glass-primary"');
  fs.writeFileSync(filePath, content, 'utf8');
};

['login/page.tsx', 'register/page.tsx', 'forgot-password/page.tsx', 'update-password/page.tsx'].forEach(f => {
  fixFile(path.join(dir, f));
});

// For update-password specifically, the previous regex might have left a mess
const updateFile = path.join(dir, 'update-password/page.tsx');
let updateContent = fs.readFileSync(updateFile, 'utf8');
updateContent = updateContent.replace(/className=\{ tn-glass-primary \\\}/g, 'className="btn-glass-primary"');
fs.writeFileSync(updateFile, updateContent, 'utf8');

console.log('Fixed files');
