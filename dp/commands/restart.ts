export default function restart(service: string) {
  console.log(`🔁 Restarting: ${service}`);
  const { execSync } = require('child_process');
  execSync(`kubectl rollout restart deployment/${service}`, { stdio: 'inherit' });
}
