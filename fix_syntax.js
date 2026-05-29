const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? 
      walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

const dir = 'C:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src';

walkDir(dir, function(filePath) {
  if (filePath.endsWith('.tsx') || filePath.endsWith('.ts')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let changed = false;
    
    if (content.includes('className={glass-input-wrapper }')) {
        content = content.replace(/className=\{glass-input-wrapper \}/g, 'className="glass-input-wrapper"');
        changed = true;
    }
    
    if (content.includes('className={glass-input }')) {
        content = content.replace(/className=\{glass-input \}/g, 'className="glass-input"');
        changed = true;
    }

    if (changed) {
        fs.writeFileSync(filePath, content, 'utf8');
        console.log('Fixed syntax in', filePath);
    }
  }
});
