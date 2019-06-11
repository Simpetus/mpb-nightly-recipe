# Conda Recipe for MPB Nightly Build

## Steps to update

Whenever a new official `MPB` tarball is released on GitHub, `recipe/meta.yaml` requires the following changes:

1. Increment the version number (the `version` jinja variable). The nightly build should be one minor version above the most recent official release, followed by `.dev`. For example, if the current nightly package version is `1.8.1.dev`, and a new MPB `1.9.0` is released, the the nightly package version should become `1.9.1.dev`.

2. Reset the `buildnumber` jinja variable to `0`.

3. Verify that all `build`, `host`, and `run` dependencies are up to date in the `requirements` section.

4. Verify that the build steps in `recipe/build.sh` are up to date.

## Cron Jobs

Setting up a daily cron job to call `trigger_mpb.sh` will automatically ensure that the nightly build is always up to date.

1. Set up some local directories and files.

```bash
# You can put these anywhere you like. Just make sure the corresponding
# environment variables in `trigger_mpb.sh` match up.
mkdir $HOME/cron
mkdir $HOME/recipes

# Set up a local clone of this repo. You must have ssh access to the repo.
pushd $HOME/recipes
git clone git@github.com:Simpetus/mpb-nightly-recipe.git
popd

# Create a file with the most recent commit hash from NanoComp/mpb.git
git ls-remote git://github.com/NanoComp/mpb.git refs/heads/master | cut -f 1 > $HOME/cron/latest_mpb_commit.txt

cp $HOME/recipes/mpb-nightly-recipe/trigger_mpb.sh $HOME/cron

# Adjust environment variables in $HOME/cron/trigger_mpb.sh if necessary
```

2. Configure your `crontab` file to run the script every day

```bash
# Enter edit mode for your `crontab` file
crontab -e

# Add this line, which will run `trigger_mpb.sh` at 8:20 am Monday through Friday,
# and save the output at $HOME/cron/mpb-<MONTH>.<DAY>.out. This job should start
# about 20 minutes after the libctl nightly build, so it can use the resulting
# package as a dependency if necessary.
20 8 * * 1-5 $HOME/cron/trigger_mpb.sh > "$HOME/cron/mpb-`date +\%m.\%d`.out" 2>&1
```

`trigger_mpb.sh` will compare the current HEAD of NanoComp/mpb.git with the contents of `$HOME/cron/latest_mpb_commit.txt`. If the commits don't match, then it will commit a bumped build number to this repo, which will trigger a Travis build, which will upload the new package.
