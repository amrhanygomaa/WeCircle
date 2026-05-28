const fs = require('fs');
const path = require('path');
function walk(d) {
  fs.readdirSync(d).forEach(f => {
    let p = path.join(d, f);
    if (fs.statSync(p).isDirectory()) {
      walk(p);
    } else if (p.endsWith('.dart')) {
      let c = fs.readFileSync(p, 'utf8');
      let nc = c.replace(/package:wesal\/api_service\.dart/g, 'package:wesal/core/api/api_service.dart');
      nc = nc.replace(/package:wesal\/app_theme\.dart/g, 'package:wesal/core/theme/app_theme.dart');
      nc = nc.replace(/package:wesal\/state_manager\.dart/g, 'package:wesal/core/state/state_manager.dart');
      if (c !== nc) fs.writeFileSync(p, nc);
    }
  });
}
walk('c:/Users/amrha/Downloads/Mobile Devices/WeCircle/mobile/lib');
console.log('Fixed Flutter imports');
