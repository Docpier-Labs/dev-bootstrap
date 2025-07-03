export default function deploy(env: string) {
  console.log(`🚀 Deploying environment: ${env}`);
  const { execSync } = require('child_process');
  execSync(`kustomize build ./k8s/${env} | kubectl apply -f -`, { stdio: 'inherit' });
}
