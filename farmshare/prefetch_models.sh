#!/bin/bash
# Download the test models into $HF_HOME on scratch while the GPU job is still queued.
# Run on the LOGIN node, inside tmux: bash ~/unsloth-skills/farmshare/prefetch_models.sh [small|all]
# Studio uses the same Hugging Face cache, so it skips downloading these later.
#
# Sizes are approximate, for the UD-Q4_K_XL files:
#   small: Qwen3.5-4B (~3 GB), gemma-4-E4B (~5 GB), gemma-4-12B-qat (~7 GB)
#   all:   adds gemma-4-26B-A4B (~16 GB) and Qwen3-30B-A3B-2507 (~17 GB), for a GPU with 24 GB or more
set -euo pipefail
export HF_HOME=/scratch/users/$USER/hf
mkdir -p "$HF_HOME"

SMALL=(
  "unsloth/Qwen3.5-4B-GGUF Qwen3.5-4B-UD-Q4_K_XL.gguf"
  "unsloth/gemma-4-E4B-it-GGUF gemma-4-E4B-it-UD-Q4_K_XL.gguf"
  "unsloth/gemma-4-12B-it-qat-GGUF gemma-4-12B-it-qat-UD-Q4_K_XL.gguf"
)
BIG=(
  "unsloth/gemma-4-26B-A4B-it-GGUF gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf"
  "unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF Qwen3-30B-A3B-Instruct-2507-UD-Q4_K_XL.gguf"
)
LIST=("${SMALL[@]}")
[ "${1:-small}" = "all" ] && LIST+=("${BIG[@]}")

# Use the hf CLI if it's installed; otherwise run it through uvx, or install it with pip --user.
if command -v hf >/dev/null 2>&1; then HF=(hf)
elif command -v uvx >/dev/null 2>&1; then HF=(uvx --from huggingface_hub hf)
else python3 -m pip install --user -q -U huggingface_hub && HF=("$HOME/.local/bin/hf"); fi

for entry in "${LIST[@]}"; do
  read -r repo file <<<"$entry"
  echo "== $repo / $file"
  "${HF[@]}" download "$repo" "$file"
done
du -sh "$HF_HOME"
