orgrepo=$1
TARGET_SITE=https://git.shufflebotham.org
pushd "${orgrepo}.git"
git push --mirror ${TARGET_SITE}/${orgrepo}
if [ -d lfs ];
then
  git lfs push --all ${TARGET_SITE}/${orgrepo}
fi
popd

