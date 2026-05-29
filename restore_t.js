const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const dir = 'C:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src';

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

walkDir(dir, function(filePath) {
  if (filePath.endsWith('.tsx') || filePath.endsWith('.ts')) {
    let content = fs.readFileSync(filePath, 'utf8');
    
    if (content.includes("t('' as any)")) {
      const relativePath = path.relative('C:/Users/amrha/Downloads/Mobile Devices/WeCircle', filePath).replace(/\\/g, '/');
      console.log(`Processing: ${relativePath}`);
      
      try {
        // Get old file content from 6cef8ba
        const oldContent = execSync(`git show 6cef8ba:${relativePath}`, { encoding: 'utf8', stdio: ['pipe', 'pipe', 'ignore'] });
        
        // Match all t('key'), t("key"), t(`key`) in old content
        const oldKeys = [];
        const oldRegex = /t\(['"`](.+?)['"`]\)/g;
        let match;
        while ((match = oldRegex.exec(oldContent)) !== null) {
          oldKeys.push(match[1]);
        }
        
        // Count t('' as any) in new content
        const newCount = (content.match(/t\('' as any\)/g) || []).length;
        
        if (oldKeys.length === newCount) {
          console.log(`Exact match (${newCount})! Restoring keys...`);
          let i = 0;
          const newContent = content.replace(/t\('' as any\)/g, () => `t('${oldKeys[i++]}')`);
          fs.writeFileSync(filePath, newContent, 'utf8');
          console.log('Restored successfully.');
        } else {
          console.log(`Mismatch in ${relativePath}: old had ${oldKeys.length}, new has ${newCount}`);
        }
      } catch (e) {
        console.log(`Could not read old file or error: ${relativePath}`);
      }
    }
  }
});
