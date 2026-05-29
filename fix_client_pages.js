const fs = require('fs');
const { execSync } = require('child_process');

function restoreClientPage(oldPath, newPath) {
  try {
    const oldContent = execSync(`git show 6cef8ba:${oldPath}`, { encoding: 'utf8' });
    const newContent = fs.readFileSync(newPath, 'utf8');
    
    const oldKeys = [];
    const oldRegex = /t\(['"`](.+?)['"`]\)/g;
    let match;
    while ((match = oldRegex.exec(oldContent)) !== null) {
      oldKeys.push(match[1]);
    }
    
    let i = 0;
    const restoredContent = newContent.replace(/t\('' as any\)/g, () => `t('${oldKeys[i++]}' as any)`);
    fs.writeFileSync(newPath, restoredContent, 'utf8');
    console.log(`Restored ${newPath} using keys from ${oldPath} (${oldKeys.length} keys)`);
  } catch (e) {
    console.error(e);
  }
}

restoreClientPage(
  'dashboard/frontend/src/app/dashboard/admissions/[id]/page.tsx',
  'dashboard/frontend/src/app/dashboard/admissions/[id]/ClientPage.tsx'
);
restoreClientPage(
  'dashboard/frontend/src/app/dashboard/students/[id]/page.tsx',
  'dashboard/frontend/src/app/dashboard/students/[id]/ClientPage.tsx'
);
