import { execSync } from "child_process";
import { existsSync } from "fs";
import * as os from "os";
import * as path from "path";

export default function sync() {
  const outputDir = path.join(os.homedir(), "Engineering", "repos");
  const org = "Docpier-Labs";

  console.log(`🔄 Syncing repos from ${org}...`);

  try {
    execSync("which ghorg", { stdio: "ignore" });
  } catch {
    console.log("📦 Installing ghorg...");
    execSync("brew install ghorg", { stdio: "inherit" });
  }

  process.env.GHORG_CLONE_TYPE = "ssh";
  process.env.GHORG_OUTPUT_DIR = outputDir;

  if (!existsSync(path.join(outputDir, "dev-bootstrap"))) {
    execSync(`ghorg clone ${org}`, { stdio: "inherit" });
  } else {
    execSync(`ghorg pull ${org}`, { stdio: "inherit" });
  }
}
