#!/bin/bash
# Starts Unsloth Studio on a FarmShare GPU node as soon as Slurm grants one.
#
# Submit from your home folder on the login node:   cd ~ && sbatch ~/unsloth-skills/farmshare/studio.sbatch
# Check it:                     squeue -u $USER -o "%i %T %r %S %N"
# Stop it:                      scancel <jobid>
#
# Slurm emails you when the job starts. When it does:
#   cat ~/studio-node.txt         # the GPU node name and the tunnel command for your Mac
#   tail -f ~/unsloth-studio-<jobid>.log  # install and Studio output
#
# Before the first submit, store a Studio password in a private file:
#   (umask 077; printf '%s' 'your-password' > ~/.studio_pass)

#SBATCH --job-name=unsloth-studio
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gpus=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=keyiyu@stanford.edu

set -uo pipefail

PORT=8888
export HF_HOME=/scratch/users/$USER/hf
export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HF_HOME"

NODE=$(hostname -s)
cat > ~/studio-node.txt <<EOF
job:  $SLURM_JOB_ID
node: $NODE
started: $(date)
log:  ~/$SLURM_JOB_NAME-$SLURM_JOB_ID.log

On your Mac run:
  ssh -N -L $PORT:$NODE:$PORT $USER@login.farmshare.stanford.edu
then open http://localhost:$PORT
EOF
echo "== Running on $NODE (job $SLURM_JOB_ID)"
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv
echo "== Internet check:"; curl -sI --max-time 10 https://huggingface.co | head -1 || echo "no internet from this node"

# Conda's base env can shadow the Python the installer picks.
conda deactivate 2>/dev/null || true

# Install on the GPU node, so the installer detects CUDA and picks GPU builds.
# A login-node install would see no GPU and pick CPU builds.
if ! command -v unsloth >/dev/null 2>&1; then
  echo "== Installing Unsloth Studio (first run only)"
  curl -fsSL https://unsloth.ai/install.sh | UNSLOTH_SKIP_AUTOSTART=1 sh
  export PATH="$HOME/.local/bin:$PATH"
  hash -r
fi
command -v unsloth || { echo "unsloth not on PATH after install; check the log above"; exit 1; }

if [ ! -s ~/.studio_pass ]; then
  echo "Missing ~/.studio_pass (see the header of this script)"; exit 1
fi
export UNSLOTH_STUDIO_PASSWORD="$(cat ~/.studio_pass)"

echo "== Starting Studio on $NODE:$PORT"
# --secure: the cluster is shared, so other users can reach this port.
exec unsloth studio --secure -H 0.0.0.0 -p "$PORT"
