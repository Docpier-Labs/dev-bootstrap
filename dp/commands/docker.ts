export default function docker(service: string) {
  console.log(`🐳 Building & pushing Docker image for: ${service}`);
  const { execSync } = require('child_process');
  execSync(`docker build -t acr.io/${service}:latest ./repos/${service} && docker push acr.io/${service}:latest`, { stdio: 'inherit' });
}
