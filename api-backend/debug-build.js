import { execSync } from 'child_process';
try {
  console.log(execSync('npx vite build', { encoding: 'utf-8' }));
} catch (e) {
  console.error("STDOUT:", e.stdout);
  console.error("STDERR:", e.stderr);
}
