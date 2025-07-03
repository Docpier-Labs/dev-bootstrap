export default function logs(service: string) {
  console.log(`📜 Logs for: ${service}`);
  const { execSync } = require('child_process');
  execSync(`kubectl logs deployment/${service} --tail=100 -f`, { stdio: 'inherit' });
}
