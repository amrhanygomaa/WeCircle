const fs = require('fs');
const files = [
  'dashboard/frontend/src/modules/dashboard/components/TeacherWizard.tsx',
  'dashboard/frontend/src/modules/dashboard/components/SupervisorWizard.tsx',
  'dashboard/frontend/src/modules/dashboard/components/DriverWizard.tsx'
];

for (const f of files) {
  let content = fs.readFileSync(f, 'utf8');
  
  content = content.replace(/import { supabase } from "@\/core\/auth\/supabase";/g, 
    'import { uploadToS3 } from "@/core/api/apiClient";');
    
  // Find the block starting from const ext = file.name.split('.').pop();
  content = content.replace(/const ext = file\.name\.split\('\.'\)\.pop\(\);[\s\S]*?const \{\s*data:\s*\{\s*publicUrl\s*\}\s*\} = supabase\.storage[\s\S]*?getPublicUrl\(`admissions\/\$\{fileName\}`\);/g, 
    'const publicUrl = await uploadToS3(file, "admissions");');

  fs.writeFileSync(f, content, 'utf8');
}
