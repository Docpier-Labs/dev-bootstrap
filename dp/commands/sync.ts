export default function sync() {
  console.log('🔄 Syncing all repos from Docpier-Labs...');
  const { execSync } = require('child_process');
  execSync('ghorg pull Docpier-Labs', { stdio: 'inherit' });
}
