export default function ctx() {
  console.log('📦 Available Kubernetes Contexts:');
  const { execSync } = require('child_process');
  execSync('kubectl config get-contexts', { stdio: 'inherit' });
}
