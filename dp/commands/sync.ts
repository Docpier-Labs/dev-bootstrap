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

  process.env.GHORG_ORG = "Docpier-Labs";
  process.env.GHORG_SSH = "true";
  process.env.GHORG_CLONE_TYPE = "org";
  process.env.GHORG_OUTPUT_DIR = outputDir;
  process.env.GHORG_SKIP_ARCHIVED = "true";
  process.env.GHORG_BRANCH = "main";
  process.env.GHORG_OVERWRITE = "false";

  execSync(`ghorg clone ${org}`, { stdio: "inherit" });
}
