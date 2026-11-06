# Running Studio on Stanford FarmShare

Facts from https://docs.farmshare.stanford.edu/docs/slurm/:
- GPU jobs need **both** `--partition=gpu` and `--qos=gpu`. The QoS defaults to `normal` otherwise.
- `--gpus` / `-G` sets the number of GPUs; none are given by default.
- Home has a 50 GB limit. Scratch is at `/scratch/users/$USER` and is purged after 90 days without changes.

`sinfo` showed GPU nodes `oat-[01-06]` with 4 GPUs each and a 2-day time limit.

## One-time prep (login node, while you wait for a GPU)

```bash
tmux new -s prep
cd ~ && git clone https://github.com/keyiyu0331/unsloth-skills   # or: cd ~/unsloth-skills && git pull
echo 'export HF_HOME=/scratch/users/$USER/hf' >> ~/.bashrc
(umask 077; printf '%s' 'PICK-A-PASSWORD' > ~/.studio_pass)

# Skills folder: link this repo's skills, plus the maintainer's examples
mkdir -p ~/.agents/skills
for d in ~/unsloth-skills/skills/*/; do ln -sfn "$d" ~/.agents/skills/$(basename "$d"); done
# Copy the example zips from your Mac with: scp sandbox-scout.zip train-replay.zip keyiyu@login.farmshare.stanford.edu:~
cd ~/.agents/skills && unzip -o ~/sandbox-scout.zip && unzip -o ~/train-replay.zip && ls

# Download models now, so the GPU time goes to testing
bash ~/unsloth-skills/farmshare/prefetch_models.sh small   # use 'all' once you know the GPU has 24 GB or more
```

## Get a GPU and get notified

```bash
scancel <old pending salloc job>      # don't keep two requests in the queue
cd ~ && sbatch ~/unsloth-skills/farmshare/studio.sbatch
squeue -u $USER -o "%i %T %r %S %N"   # %S = Slurm's estimated start time
```

The job emails `keyiyu@stanford.edu` when it starts (assuming FarmShare sends Slurm mail; the docs don't say). Then it installs Studio on the first run and starts it with no further input. Nothing needs to stay open while it waits.

If the email never arrives, check `squeue` or `cat ~/studio-node.txt`. You can also run this from your Mac and get a macOS notification:

```bash
# Mac: polls every 2 minutes (needs one Duo approval; reuse it with ControlMaster in ~/.ssh/config)
while ! ssh farmshare 'test -f ~/studio-node.txt && squeue -h -u $USER -t R -n unsloth-studio | grep -q .'; do sleep 120; done; \
  osascript -e 'display notification "GPU job is running" with title "FarmShare"'; ssh farmshare cat ~/studio-node.txt
```

## When it starts

1. Run `cat ~/studio-node.txt`. It shows the node name and the exact tunnel command.
2. Run `tail -f ~/unsloth-studio-<jobid>.log` and wait for Studio to report that it's listening. The first run includes the install.
3. On your Mac, run the tunnel command from step 1, then open http://localhost:8888 and log in with your password.
4. Check that the skills are listed under **Manage skills**, and turn **Tools** on.
5. Run `sandbox-scout` first, then work through `samples/prompts.md`. Log each run in `results/results.csv`.

The 4-hour job ends on its own. To give the GPU back early, run `scancel <jobid>`.
