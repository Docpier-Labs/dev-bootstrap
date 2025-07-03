import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

const ORG = 'Docpier-Labs';
const OUTPUT_DIR = path.resolve(process.env.HOME || '~', 'Engineering', 'repos');

export default function sync() {
  console.log(`🔄 Syncing all repos from org '${ORG}' into ${OUTPUT_DIR}`);

  const ghListCommand = `gh repo list ${ORG} --limit 1000 --json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv'`;
  const output = execSync(ghListCommand, { encoding: 'utf-8' });

  const lines = output.split('\n').filter(Boolean);

  for (const line of lines) {
    const [name, sshUrl] = line.split('\t');
    const repoPath = path.join(OUTPUT_DIR, name);

    if (fs.existsSync(repoPath)) {
      console.log(`📁 ${name} already exists. Pulling latest changes...`);
      execSync('git pull', { cwd: repoPath, stdio: 'inherit' });
    } else {
      console.log(`📦 Cloning ${name}...`);
      execSync(`git clone ${sshUrl}`, { cwd: OUTPUT_DIR, stdio: 'inherit' });
    }
  }

  console.log('✅ Repo sync complete.');
}
