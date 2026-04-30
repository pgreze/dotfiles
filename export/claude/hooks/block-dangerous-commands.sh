#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

block() {
  echo "$1" >&2
  exit 2
}

# ─── Git: destructive / irreversible ─────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bgit\s+push\s+.*--force\b' &&
  block "BLOCKED: git push --force — use --force-with-lease instead"
echo "$COMMAND" | grep -qiE '\bgit\s+push\s+.*-f\b' &&
  block "BLOCKED: git push -f — use --force-with-lease instead"
echo "$COMMAND" | grep -qiE '\bgit\s+reset\s+--hard\b' &&
  block "BLOCKED: git reset --hard — this discards uncommitted work"
echo "$COMMAND" | grep -qiE '\bgit\s+clean\s+.*-fd\b' &&
  block "BLOCKED: git clean -fd — permanently deletes untracked files"
echo "$COMMAND" | grep -qiE '\bgit\s+checkout\s+--\s+\.' &&
  block "BLOCKED: git checkout -- . — discards all unstaged changes"
echo "$COMMAND" | grep -qiE '\bgit\s+branch\s+-D\b' &&
  block "BLOCKED: git branch -D — force-deletes branch without merge check"
echo "$COMMAND" | grep -qiE '\bgit\s+rebase\s+.*-i\b' &&
  block "BLOCKED: git rebase -i — interactive rebase requires user input"
echo "$COMMAND" | grep -qiE '\bgit\s+stash\s+drop\b' &&
  block "BLOCKED: git stash drop — permanently deletes a stash entry"
echo "$COMMAND" | grep -qiE '\bgit\s+stash\s+clear\b' &&
  block "BLOCKED: git stash clear — permanently deletes all stashes"
echo "$COMMAND" | grep -qiE '\bgit\s+reflog\s+expire\b' &&
  block "BLOCKED: git reflog expire — destroys recovery history"
echo "$COMMAND" | grep -qiE '\bgit\s+gc\s+--prune=now\b' &&
  block "BLOCKED: git gc --prune=now — permanently removes unreachable objects"
echo "$COMMAND" | grep -qiE '\bgit\s+filter-branch\b' &&
  block "BLOCKED: git filter-branch — rewrites repository history"
echo "$COMMAND" | grep -qiE '\bgit\s+update-ref\s+-d\b' &&
  block "BLOCKED: git update-ref -d — deletes refs directly"

# ─── Filesystem: catastrophic deletions ──────────────────────────────────────
echo "$COMMAND" | grep -qiE '\brm\s+.*-rf\s+/' &&
  block "BLOCKED: rm -rf / — catastrophic filesystem deletion"
echo "$COMMAND" | grep -qiE '\brm\s+.*-rf\s+~' &&
  block "BLOCKED: rm -rf ~ — deletes home directory"
echo "$COMMAND" | grep -qiE '\brm\s+.*-rf\s+\.' &&
  block "BLOCKED: rm -rf . — deletes current directory tree"
echo "$COMMAND" | grep -qiE '\brm\s+.*-rf\s+\*' &&
  block "BLOCKED: rm -rf * — deletes everything in current directory"
echo "$COMMAND" | grep -qiE '\bsudo\s+rm\b' &&
  block "BLOCKED: sudo rm — elevated deletion is too dangerous"
echo "$COMMAND" | grep -qiE '\bchmod\s+-R\s+777\b' &&
  block "BLOCKED: chmod -R 777 — opens all permissions recursively"
echo "$COMMAND" | grep -qiE '\bchown\s+-R\b' &&
  block "BLOCKED: chown -R — recursive ownership change"
echo "$COMMAND" | grep -qiE ':\(\)\s*\{\s*:\|:\s*&\s*\}\s*;' &&
  block "BLOCKED: fork bomb detected"
echo "$COMMAND" | grep -qiE '\bmkfs\b' &&
  block "BLOCKED: mkfs — formats a filesystem"
echo "$COMMAND" | grep -qiE '\bdd\s+.*of=/' &&
  block "BLOCKED: dd writing to a device/root path"

# ─── Secrets / credentials ───────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bcat\s+.*\.env\b' &&
  block "BLOCKED: cat .env — avoid leaking secrets into context"
echo "$COMMAND" | grep -qiE '\bcat\s+.*credentials\b' &&
  block "BLOCKED: cat credentials — avoid leaking secrets into context"
echo "$COMMAND" | grep -qiE '\bcat\s+.*\.pem\b' &&
  block "BLOCKED: cat .pem — avoid leaking private keys"
echo "$COMMAND" | grep -qiE '\bcat\s+.*\.key\b' &&
  block "BLOCKED: cat .key — avoid leaking private keys"
echo "$COMMAND" | grep -qiE '\bcat\s+.*id_rsa\b' &&
  block "BLOCKED: cat id_rsa — avoid leaking SSH private keys"
echo "$COMMAND" | grep -qiE '\bcat\s+.*\.jks\b' &&
  block "BLOCKED: cat .jks — avoid leaking Java KeyStore"
echo "$COMMAND" | grep -qiE '\bcat\s+.*keystore\b' &&
  block "BLOCKED: cat keystore — avoid leaking signing keys"
echo "$COMMAND" | grep -qiE '\bcat\s+.*google-services\.json\b' &&
  block "BLOCKED: cat google-services.json — avoid leaking Firebase config"
echo "$COMMAND" | grep -qiE '\bprintenv\b' &&
  block "BLOCKED: printenv — avoid leaking environment variables"

# ─── Android / Gradle ────────────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\b(gradlew?|gradle)\s+.*clean\s+.*assembleRelease\b' &&
  block "BLOCKED: release builds should go through CI, not local"
echo "$COMMAND" | grep -qiE '\badb\s+shell\s+.*rm\b' &&
  block "BLOCKED: adb shell rm — deleting files on device"
echo "$COMMAND" | grep -qiE '\badb\s+shell\s+.*wipe\b' &&
  block "BLOCKED: adb wipe — factory resets device"
echo "$COMMAND" | grep -qiE '\badb\s+shell\s+pm\s+uninstall\b' &&
  block "BLOCKED: adb pm uninstall — removes apps from device"
echo "$COMMAND" | grep -qiE '\bkeytool\s+.*-delete\b' &&
  block "BLOCKED: keytool -delete — removes keys from keystore"
echo "$COMMAND" | grep -qiE '\bjarsigner\b' &&
  block "BLOCKED: jarsigner — signing should go through CI"
echo "$COMMAND" | grep -qiE '\bapksigner\b' &&
  block "BLOCKED: apksigner — signing should go through CI"
echo "$COMMAND" | grep -qiE '\b(gradlew?|gradle)\s+.*publish\b' &&
  block "BLOCKED: gradle publish — publishing should go through CI"
echo "$COMMAND" | grep -qiE '\b(gradlew?|gradle)\s+.*upload\b' &&
  block "BLOCKED: gradle upload — uploads should go through CI"

# ─── Flutter ─────────────────────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bflutter\s+.*--release\b.*publish\b' &&
  block "BLOCKED: flutter release publish — should go through CI"
echo "$COMMAND" | grep -qiE '\bflutter\s+pub\s+publish\b' &&
  block "BLOCKED: flutter pub publish — publishing packages should be deliberate"
echo "$COMMAND" | grep -qiE '\bflutter\s+channel\s+(master|beta)\b' &&
  block "BLOCKED: switching to unstable Flutter channel"

# ─── Node / Web ──────────────────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bnpm\s+publish\b' &&
  block "BLOCKED: npm publish — publishing should go through CI"
echo "$COMMAND" | grep -qiE '\byarn\s+publish\b' &&
  block "BLOCKED: yarn publish — publishing should go through CI"
echo "$COMMAND" | grep -qiE '\bnpx\s+.*rimraf\s+/' &&
  block "BLOCKED: npx rimraf / — catastrophic deletion"
echo "$COMMAND" | grep -qiE '\bnpm\s+.*--force\b' &&
  block "BLOCKED: npm --force — force installs bypass safety checks"
echo "$COMMAND" | grep -qiE '\bnpm\s+unpublish\b' &&
  block "BLOCKED: npm unpublish — removes published packages"
echo "$COMMAND" | grep -qiE '\bnpm\s+deprecate\b' &&
  block "BLOCKED: npm deprecate — marks packages as deprecated"
echo "$COMMAND" | grep -qiE '\bnpm\s+token\b' &&
  block "BLOCKED: npm token — avoid leaking auth tokens"

# ─── Docker ──────────────────────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bdocker\s+system\s+prune\s+-a\b' &&
  block "BLOCKED: docker system prune -a — removes all images and containers"
echo "$COMMAND" | grep -qiE '\bdocker\s+rm\s+.*-f\b' &&
  block "BLOCKED: docker rm -f — force removes running containers"
echo "$COMMAND" | grep -qiE '\bdocker\s+rmi\s+.*-f\b' &&
  block "BLOCKED: docker rmi -f — force removes images"
echo "$COMMAND" | grep -qiE '\bdocker\s+volume\s+prune\b' &&
  block "BLOCKED: docker volume prune — deletes all unused volumes"
echo "$COMMAND" | grep -qiE '\bdocker\s+push\b' &&
  block "BLOCKED: docker push — pushing images should go through CI"

# ─── Cloud / infra ───────────────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bgcloud\s+.*delete\b' &&
  block "BLOCKED: gcloud delete — destroying cloud resources"
echo "$COMMAND" | grep -qiE '\bkubectl\s+delete\b' &&
  block "BLOCKED: kubectl delete — destroying Kubernetes resources"
echo "$COMMAND" | grep -qiE '\bterraform\s+destroy\b' &&
  block "BLOCKED: terraform destroy — destroying infrastructure"
echo "$COMMAND" | grep -qiE '\baws\s+.*--delete\b' &&
  block "BLOCKED: aws --delete — destroying AWS resources"
echo "$COMMAND" | grep -qiE '\bheroku\s+.*destroy\b' &&
  block "BLOCKED: heroku destroy — destroying Heroku apps"
echo "$COMMAND" | grep -qiE '\bfirebase\s+.*delete\b' &&
  block "BLOCKED: firebase delete — destroying Firebase resources"

# ─── Database ────────────────────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bDROP\s+(DATABASE|TABLE|SCHEMA)\b' &&
  block "BLOCKED: DROP DATABASE/TABLE/SCHEMA — destructive SQL"
echo "$COMMAND" | grep -qiE '\bTRUNCATE\s+TABLE\b' &&
  block "BLOCKED: TRUNCATE TABLE — deletes all rows"
echo "$COMMAND" | grep -qiE '\bDELETE\s+FROM\b.*(?!WHERE)' &&
  block "BLOCKED: DELETE FROM without WHERE — deletes all rows"
echo "$COMMAND" | grep -qiE '\b(rails|rake)\s+db:reset\b' &&
  block "BLOCKED: db:reset — drops and recreates the database"
echo "$COMMAND" | grep -qiE '\b(rails|rake)\s+db:drop\b' &&
  block "BLOCKED: db:drop — drops the database"
echo "$COMMAND" | grep -qiE '\b(rails|rake)\s+db:schema:load\b' &&
  block "BLOCKED: db:schema:load — replaces database schema destructively"
echo "$COMMAND" | grep -qiE '\bdjango.*\bflush\b' &&
  block "BLOCKED: django flush — deletes all data from database"
echo "$COMMAND" | grep -qiE '\bmanage\.py\s+flush\b' &&
  block "BLOCKED: manage.py flush — deletes all data from database"
echo "$COMMAND" | grep -qiE '\bprisma\s+(db\s+push\s+--force-reset|migrate\s+reset)\b' &&
  block "BLOCKED: prisma reset — drops and recreates the database"
echo "$COMMAND" | grep -qiE '\bmongosh?\b.*\bdropDatabase\b' &&
  block "BLOCKED: dropDatabase — drops the entire MongoDB database"
echo "$COMMAND" | grep -qiE '\bredis-cli\s+FLUSHALL\b' &&
  block "BLOCKED: redis FLUSHALL — deletes all keys from all databases"
echo "$COMMAND" | grep -qiE '\bredis-cli\s+FLUSHDB\b' &&
  block "BLOCKED: redis FLUSHDB — deletes all keys from current database"
echo "$COMMAND" | grep -qiE '\bpsql\b.*\bDROP\b' &&
  block "BLOCKED: psql DROP — destructive PostgreSQL operation"
echo "$COMMAND" | grep -qiE '\bmysql\b.*\bDROP\b' &&
  block "BLOCKED: mysql DROP — destructive MySQL operation"

# ─── Supabase ────────────────────────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bsupabase\s+db\s+reset\b' &&
  block "BLOCKED: supabase db reset — drops and recreates the database"
echo "$COMMAND" | grep -qiE '\bsupabase\s+projects?\s+delete\b' &&
  block "BLOCKED: supabase project delete — permanently deletes a project"
echo "$COMMAND" | grep -qiE '\bsupabase\s+stop\b.*--backup\b' &&
  block "BLOCKED: supabase stop --backup — stops local and may affect data"
echo "$COMMAND" | grep -qiE '\bsupabase\s+migration\s+repair\b' &&
  block "BLOCKED: supabase migration repair — modifies migration history"
echo "$COMMAND" | grep -qiE '\bsupabase\s+db\s+push\s+--force\b' &&
  block "BLOCKED: supabase db push --force — force-applies migrations, may cause data loss"
echo "$COMMAND" | grep -qiE '\bsupabase\s+link\b.*--password\b' &&
  block "BLOCKED: supabase link --password — avoid leaking database password in shell history"
echo "$COMMAND" | grep -qiE '\bsupabase\s+orgs?\s+delete\b' &&
  block "BLOCKED: supabase org delete — permanently deletes an organization"
echo "$COMMAND" | grep -qiE '\bsupabase\s+storage\s+rm\b' &&
  block "BLOCKED: supabase storage rm — deletes storage objects"
echo "$COMMAND" | grep -qiE '\bsupabase\s+functions?\s+delete\b' &&
  block "BLOCKED: supabase functions delete — deletes Edge Functions"
echo "$COMMAND" | grep -qiE '\bsupabase\s+secrets?\s+list\b' &&
  block "BLOCKED: supabase secrets list — avoid leaking secrets into context"
echo "$COMMAND" | grep -qiE '\bsupabase\s+domains?\s+delete\b' &&
  block "BLOCKED: supabase domains delete — removes custom domain"

# ─── Networking / exfiltration ───────────────────────────────────────────────
echo "$COMMAND" | grep -qiE '\bcurl\s+.*-X\s*(POST|PUT|DELETE)\b' &&
  block "BLOCKED: curl with mutating HTTP method — could modify remote resources"
echo "$COMMAND" | grep -qiE '\bwget\s+.*\|\s*bash\b' &&
  block "BLOCKED: wget | bash — executing remote code"
echo "$COMMAND" | grep -qiE '\bcurl\s+.*\|\s*bash\b' &&
  block "BLOCKED: curl | bash — executing remote code"
echo "$COMMAND" | grep -qiE '\bcurl\s+.*\|\s*sh\b' &&
  block "BLOCKED: curl | sh — executing remote code"

exit 0
