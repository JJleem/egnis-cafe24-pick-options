#!/usr/bin/env bash
# 로컬 Terminal.app 에서 실행하세요. (Claude 세션 shell 은 Desktop 접근이 막혀 있음)
#   chmod +x push-to-github.sh && ./push-to-github.sh
set -euo pipefail

cd "$(dirname "$0")"

REMOTE_URL="https://github.com/JJleem/egnis-cafe24-pick-options.git"

# 1) git 초기화 (이미 있으면 건너뜀)
if [ ! -d .git ]; then
  git init -b main
fi

git config user.name  >/dev/null 2>&1 || git config user.name  "JJleem"
git config user.email >/dev/null 2>&1 || git config user.email "leemjaejun@gmail.com"

# 2) 원격 연결 (없으면 추가)
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

# 3) 커밋
git add -A
git commit -m "카페24 골라담기 옵션 UI + 모바일 바텀시트, handoff 문서 추가

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>" || echo "커밋할 변경 없음(이미 커밋됨)"

# 4) push
#    원격에 이미 커밋(예: GitHub 생성 시 README)이 있으면 먼저 합친다.
git fetch origin main >/dev/null 2>&1 || true
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  git pull --rebase origin main --allow-unrelated-histories || {
    echo ""
    echo "⚠️ 원격과 충돌이 났습니다. 충돌 해결 후 아래를 실행하세요:"
    echo "    git rebase --continue && git push -u origin main"
    exit 1
  }
fi

git push -u origin main

echo ""
echo "완료 → https://github.com/JJleem/egnis-cafe24-pick-options"
