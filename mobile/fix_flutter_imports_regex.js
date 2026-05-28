const fs = require('fs');
const path = require('path');

function walk(dir) {
  fs.readdirSync(dir).forEach(file => {
    let p = path.join(dir, file);
    if (fs.statSync(p).isDirectory()) {
      walk(p);
    } else if (p.endsWith('.dart')) {
      let content = fs.readFileSync(p, 'utf8');
      let newContent = content;

      // Fix imports for app_theme
      newContent = newContent.replace(/import\s+['"](?:\.\.\/)*app_theme\.dart['"];/g, "import 'package:wesal/core/theme/app_theme.dart';");
      newContent = newContent.replace(/import\s+['"]app_theme\.dart['"];/g, "import 'package:wesal/core/theme/app_theme.dart';");
      newContent = newContent.replace(/import\s+['"]package:wesal\/app_theme\.dart['"];/g, "import 'package:wesal/core/theme/app_theme.dart';");

      // Fix imports for state_manager
      newContent = newContent.replace(/import\s+['"](?:\.\.\/)*state_manager\.dart['"];/g, "import 'package:wesal/core/state/state_manager.dart';");
      newContent = newContent.replace(/import\s+['"]state_manager\.dart['"];/g, "import 'package:wesal/core/state/state_manager.dart';");
      newContent = newContent.replace(/import\s+['"]package:wesal\/state_manager\.dart['"];/g, "import 'package:wesal/core/state/state_manager.dart';");

      // Fix imports for api_service
      newContent = newContent.replace(/import\s+['"](?:\.\.\/)*api_service\.dart['"];/g, "import 'package:wesal/core/api/api_service.dart';");
      newContent = newContent.replace(/import\s+['"]api_service\.dart['"];/g, "import 'package:wesal/core/api/api_service.dart';");
      newContent = newContent.replace(/import\s+['"]package:wesal\/api_service\.dart['"];/g, "import 'package:wesal/core/api/api_service.dart';");

      // Fix specific issues in moved files
      if (p.endsWith('app_theme.dart')) {
        newContent = newContent.replace(/import\s+['"]core\/colors\.dart['"];/g, "import 'package:wesal/core/colors.dart';");
        newContent = newContent.replace(/import\s+['"]core\/styles\.dart['"];/g, "import 'package:wesal/core/styles.dart';");
      }
      if (p.endsWith('api_service.dart')) {
        newContent = newContent.replace(/import\s+['"]core\/config\/api_config\.dart['"];/g, "import 'package:wesal/core/config/api_config.dart';");
      }
      
      if (content !== newContent) {
        fs.writeFileSync(p, newContent);
      }
    }
  });
}

walk('c:/Users/amrha/Downloads/Mobile Devices/WeCircle/mobile/lib');
console.log('Fixed Dart imports');
