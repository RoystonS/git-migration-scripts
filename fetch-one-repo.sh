# Fetch/update a single repo from Git

ownerrepo=$1

echo $ownerrepo:
# We start with a depth of 1 because some repos are MASSIVE
if [ ! -d "data/${ownerrepo}.git" ]; then
  git clone --mirror --depth 1 https://github.ibm.com/${ownerrepo} "data/${ownerrepo}.git"
fi

if [ ! -d "data/${ownerrepo}.git" ]; then
  # Wiki?
  return
fi

pushd "data/${ownerrepo}.git" >/dev/null
# Ensure it's a mirror (some repos were cloned without --mirror originally)
git config remote.origin.fetch "+refs/*:refs/*"
git config remote.origin.mirror true

# If the repo is still shallow, deepen it until it isn't
wasShallow=false
deepenBy=1000
while $(git rev-parse --is-shallow-repository) = "true"; do
  wasShallow=true
  echo Deepening by ${deepenBy}
  if git fetch --deepen ${deepenBy}; then
    # We managed to deepen by N.  Try N*1.5 next time
    deepenBy=$(expr ${deepenBy} \* 3 / 2)
  else
    # We failed to deepen by N. Try N/10 next time
    deepenBy=$(expr ${deepenBy} / 10)
  fi
  if [ "${deepenBy}" == "0" ]; then
    # Oh dear. Our calculation of the next amount to deepen by has become 0. Round up to 1.
    deepenBy=1
  fi
done

# We now have a non-shallow repo

# Make sure we've got all the tags
git fetch --tags
git fetch --all
# Get rid of tags/branches that don't exist any more
git fetch --prune

# Ensure we have all LFS blobs
# Checking for LFS blobs is expensive for large repos, so if
# we detect repos without LFS, we mark them with an i2-no-lfs file
if [[ ! -f i2-no-lfs ]] || [[ -d lfs ]]; then
  echo Checking LFS
  git lfs fetch --all

  # If this repo does not ACTUALLY use lfs, there'll be a stray lfs/tmp left over from that.
  rmdir lfs/tmp 2>/dev/null
  rmdir lfs 2>/dev/null
  if [[ ! -d lfs ]]; then
    date >i2-no-lfs
  fi
fi

if [[ "${wasShallow}" == "true" ]]; then
  echo UNSHALLOWED. GCing
  git gc --prune=now
fi

git repack

popd >/dev/null
