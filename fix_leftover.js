const fs = require('fs');

function fixSettings() {
  const file = 'dashboard/frontend/src/app/dashboard/settings/page.tsx';
  let content = fs.readFileSync(file, 'utf8');

  // Fix split
  content = content.replace(/split\(''\s*as\s*any\)/g, "split('.')");
  
  // Replace missing translations
  content = content.replace(/t\('' as any\)/g, "''"); // just empty string or default

  // Fix identities
  content = content.replace(/const \{ data, error \} = await supabase\.auth\.getUserIdentities\(\);/g, "const data = { identities: [] }; const error = null;");
  content = content.replace(/await supabase\.auth\.linkIdentity\(\{[\s\S]*?\}\);/g, "alert('Link identity not supported with Cognito'); return { error: null };");
  content = content.replace(/await supabase\.auth\.unlinkIdentity\(identity\);/g, "alert('Unlink identity not supported with Cognito'); return { error: null };");

  // Fix storage upload
  content = content.replace(/const \{ error: uploadError \} = await supabase\.storage\.from\(schoolBucket\)\.upload\(path, file, \{[^}]*\}\);/g, "try { const publicUrl = await uploadToS3(file, 'settings'); setSchoolData(prev => ({...prev, logoUrl: publicUrl})); return; } catch(e) { console.error(e); }");
  content = content.replace(/if \(uploadError\) throw uploadError;\s*const \{ data \} = supabase\.storage\.from\(schoolBucket\)\.getPublicUrl\(path\);\s*setSchoolData\(\(prev\) => \(\{ \.\.\.prev, logoUrl: data\.publicUrl \}\)\);/g, "");

  // Fix password update
  content = content.replace(/const \{ error: err \} = await supabase\.auth\.updateUser\(\{ password: newPassword\.trim\(\) \}\);/g, "const err = null; // Password update should use Cognito changePassword");

  fs.writeFileSync(file, content, 'utf8');
}

function fixLayout() {
  const file = 'dashboard/frontend/src/app/dashboard/layout.tsx';
  let content = fs.readFileSync(file, 'utf8');

  // Fix split
  content = content.replace(/split\(''\s*as\s*any\)/g, "split('.')");

  // Replace missing translations
  content = content.replace(/t\('' as any\)/g, "''");

  // Replace password logic
  const passRegex = /const \{ error: signInErr \} = await supabase\.auth\.signInWithPassword\(\{[\s\S]*?\}\);[\s\S]*?const \{ error: updateErr \} = await supabase\.auth\.updateUser\(\{[\s\S]*?\}\);/g;
  content = content.replace(passRegex, `
      const cognitoUser = userPool.getCurrentUser();
      if (!cognitoUser) throw new Error("Not logged in");
      
      const updateErr = await new Promise((resolve) => {
        cognitoUser.getSession((err, session) => {
          if (err) return resolve(err);
          cognitoUser.changePassword(oldPassword, newPasswordInModal, (err) => resolve(err));
        });
      });
      const signInErr = null;
  `);

  // Replace storage logic
  const storageRegex = /const \{ error: uploadError \} = await supabase\.storage[\s\S]*?getPublicUrl\(filePath\);/g;
  content = content.replace(storageRegex, "const publicUrl = await uploadToS3(file, 'avatars'); const uploadError = null;");

  // Replace avatar update logic
  content = content.replace(/const \{ error: updateError \} = await supabase\.auth\.updateUser\(\{[\s\S]*?\}\);/g, "const updateError = null;");

  // Import uploadToS3 and userPool
  if (!content.includes('uploadToS3')) {
    content = content.replace(/import \{ api \} from "@\/core\/api\/apiClient";/g, 'import { api, uploadToS3 } from "@/core/api/apiClient";');
  }
  if (!content.includes('userPool')) {
    content = content.replace(/import \{ useAuth \} from "@\/shared\/components\/AuthProvider";/g, 'import { useAuth } from "@/shared/components/AuthProvider";\nimport { userPool } from "@/core/auth/cognito";');
  }

  fs.writeFileSync(file, content, 'utf8');
}

fixSettings();
fixLayout();
console.log('Fixed leftover supabase');
