const fs = require('fs');
const cFile = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/backend/src/modules/student/student.controller.ts';
let c = fs.readFileSync(cFile, 'utf8');
c = c.replace(/from "\.\.\//g, 'from "../../');
c = c.replace(/from "\.\/dashboard\.controller"/g, 'from "../../controllers/dashboard.controller"');
fs.writeFileSync(cFile, c);

const rFile = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/backend/src/modules/student/student.routes.ts';
if (fs.existsSync(rFile)) {
  let r = fs.readFileSync(rFile, 'utf8');
  r = r.replace(/from "\.\.\/\.\.\/controllers\/student\.controller"/g, 'from "./student.controller"');
  fs.writeFileSync(rFile, r);
}

const iFile = 'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/backend/src/routes/index.ts';
let i = fs.readFileSync(iFile, 'utf8');
i = i.replace(/from "\.\/modules\/student\.routes"/g, 'from "../modules/student/student.routes"');
fs.writeFileSync(iFile, i);
console.log("Fixed!");
