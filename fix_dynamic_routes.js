const fs = require('fs');

const files = [
  'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app/dashboard/admissions/[id]/page.tsx',
  'c:/Users/amrha/Downloads/Mobile Devices/WeCircle/dashboard/frontend/src/app/dashboard/students/[id]/page.tsx'
];

files.forEach(f => {
    if (fs.existsSync(f)) {
        let content = fs.readFileSync(f, 'utf8');
        if (!content.includes('generateStaticParams')) {
            content += "\n\nexport function generateStaticParams() { return []; }\n";
            fs.writeFileSync(f, content, 'utf8');
            console.log('Added generateStaticParams to ' + f);
        }
    }
});
