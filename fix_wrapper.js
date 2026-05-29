const fs = require('fs');
const path = require('path');

function fixWrapper(routeDir) {
    const pagePath = path.join(routeDir, 'page.tsx');
    const newPageContent = "import ClientPage from './ClientPage';\n\nexport function generateStaticParams() {\n  return [];\n}\n\nexport default function Page() {\n  return <ClientPage />;\n}\n";
    fs.writeFileSync(pagePath, newPageContent, 'utf8');
}

fixWrapper('C:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app/dashboard/admissions/[id]');
fixWrapper('C:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app/dashboard/students/[id]');
