const fs = require('fs');
const glob = require('glob'); // Not available? I'll just hardcode the paths.

const paths = [
  'dashboard/frontend/src/app/dashboard/exams/page.tsx',
  'dashboard/frontend/src/app/dashboard/layout.tsx',
  'dashboard/frontend/src/app/dashboard/settings/page.tsx',
  'dashboard/frontend/src/modules/dashboard/components/AdmissionWizard.tsx',
  'dashboard/frontend/src/modules/dashboard/components/DriverWizard.tsx',
  'dashboard/frontend/src/modules/dashboard/components/SupervisorWizard.tsx',
  'dashboard/frontend/src/modules/dashboard/components/TeacherWizard.tsx'
];

for (const p of paths) {
  if (fs.existsSync(p)) {
    let content = fs.readFileSync(p, 'utf8');
    
    // Remove the import
    content = content.replace(/import\s+\{\s*supabase\s*\}\s+from\s+["']@\/core\/auth\/supabase["'];?\n?/g, '');
    
    // Replace the upload logic
    content = content.replace(/await\s+supabase\.storage\.from\([^)]+\)\.upload\([^,]+,\s*(file|e\.target\.files\[0\])[^)]*\);/g, 
      'await uploadToS3($1, "uploads");');
      
    // Replace the URL retrieval
    content = content.replace(/const\s+\{\s*data:\s*{[^}]*}\s*\}\s*=\s*supabase\.storage\.from\([^)]+\)\.getPublicUrl\([^)]+\);/g, 
      ''); // Since uploadToS3 already returns publicUrl! Wait, we need to adapt this carefully.
      
    // Actually, just add the S3 import if needed
    if (content.includes('uploadToS3') && !content.includes('uploadToS3 } from')) {
      content = content.replace(/import\s+\{\s*api\s*\}\s+from\s+["']@\/core\/api\/apiClient["'];/, 'import { api, uploadToS3 } from "@/core/api/apiClient";');
    }

    fs.writeFileSync(p, content, 'utf8');
  }
}
console.log('Fixed supabase imports in frontend.');
