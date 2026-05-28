const fs = require('fs');
const path = require('path');
function walk(d) {
  fs.readdirSync(d).forEach(f => {
    let p = path.join(d, f);
    if (fs.statSync(p).isDirectory()) {
      walk(p);
    } else if (p.endsWith('.ts')) {
      let c = fs.readFileSync(p, 'utf8');
      let nc = c.replace(/from "\.\.\/middlewares/g, 'from "../core/http/middlewares');
      nc = nc.replace(/from "\.\/middlewares/g, 'from "./core/http/middlewares');
      nc = nc.replace(/from "\.\.\/\.\.\/middlewares/g, 'from "../../core/http/middlewares');
      if (c !== nc) fs.writeFileSync(p, nc);
    }
  });
}
walk('c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/backend/src');
console.log('Fixed middlewares');
