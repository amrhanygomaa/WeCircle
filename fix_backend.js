const fs = require('fs');

const f1 = 'dashboard/backend/src/controllers/school.controller.ts';
fs.writeFileSync(f1, fs.readFileSync(f1, 'utf8').replace(/req\.user\.supabaseId/g, 'req.user.cognitoId'));

const f2 = 'dashboard/backend/src/controllers/student.controller.ts';
fs.writeFileSync(f2, fs.readFileSync(f2, 'utf8')
  .replace(/\.\.\/utils\/asyncHandler/g, '../core/utils/asyncHandler')
  .replace(/\.\.\/utils\/AppError/g, '../core/utils/AppError'));

const f3 = 'dashboard/backend/src/core/http/middlewares/auth.ts';
fs.writeFileSync(f3, fs.readFileSync(f3, 'utf8')
  .replace(/\.\.\/config\/prisma/g, '../../config/database')
  .replace(/\.\.\/config\/env/g, '../../config/env'));

const f4 = 'dashboard/backend/src/core/http/middlewares/mobileAuth.ts';
fs.writeFileSync(f4, fs.readFileSync(f4, 'utf8')
  .replace(/\.\.\/config\/env/g, '../../config/env')
  .replace(/\.\.\/core\/utils\/sessionStore/g, '../../utils/sessionStore'));

const f5 = 'dashboard/backend/src/core/http/middlewares/tenantScope.ts';
fs.writeFileSync(f5, fs.readFileSync(f5, 'utf8')
  .replace(/\.\.\/core\/utils\/AppError/g, '../../utils/AppError'));

const f6 = 'dashboard/backend/src/core/http/middlewares/errorHandler.ts';
fs.writeFileSync(f6, fs.readFileSync(f6, 'utf8')
  .replace(/\.\.\/core\/utils\/AppError/g, '../../utils/AppError')
  .replace(/err\.statusCode/g, '(err as any).statusCode')
  .replace(/err\.code/g, '(err as any).code')
  .replace(/err\.field/g, '(err as any).field'));
