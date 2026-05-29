const fs = require('fs');
const path = require('path');

function fixDynamicRoute(routeDir) {
    const pagePath = path.join(routeDir, 'page.tsx');
    const clientPagePath = path.join(routeDir, 'ClientPage.tsx');

    if (!fs.existsSync(pagePath)) return;

    let content = fs.readFileSync(pagePath, 'utf8');

    // Remove the generateStaticParams I added earlier
    content = content.replace(/export function generateStaticParams\(\) \{ return \[\]; \}/g, '');

    // Rename page.tsx to ClientPage.tsx
    fs.writeFileSync(clientPagePath, content, 'utf8');

    // Create a new server component page.tsx
    const newPageContent = "import ClientPage from './ClientPage';\n\nexport function generateStaticParams() {\n  return [];\n}\n\nexport default function Page({ params }: { params: { id: string } }) {\n  return <ClientPage params={params} />;\n}\n";
    fs.writeFileSync(pagePath, newPageContent, 'utf8');
    console.log('Fixed dynamic route at ' + routeDir);
}

fixDynamicRoute('C:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app/dashboard/admissions/[id]');
fixDynamicRoute('C:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app/dashboard/students/[id]');
