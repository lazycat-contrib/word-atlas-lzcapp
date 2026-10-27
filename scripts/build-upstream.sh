#!/usr/bin/env bash
# word-atlas 静态站构建：克隆上游源码（master 提交为准）→ npm ci + vite build → content/
# 由 LazyCat GitHub Action 的 buildscript 在每次构建时执行
set -euo pipefail

REPO="https://github.com/designfuchen/word-atlas.git"
REF="${LAZYCAT_UPSTREAM_REF:-}"
echo "==> building word-atlas ref: ${REF:-<default branch>}"

rm -rf .upstream content
mkdir -p content

if [ -n "$REF" ]; then
  if ! git clone --depth 1 --branch "$REF" "$REPO" .upstream 2>/dev/null; then
    echo "==> ref $REF not found, falling back to default branch"
    git clone --depth 1 "$REPO" .upstream
  fi
else
  git clone --depth 1 "$REPO" .upstream
fi

cd .upstream
echo "==> upstream commit: $(git rev-parse --short HEAD)"
npm ci
npm run build
cd ..

cp -r .upstream/dist/. content/
echo "==> content built: $(du -sh content | cut -f1)"
