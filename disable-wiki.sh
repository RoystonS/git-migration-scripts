# Turns Wiki support off for a repo
# e.g. node disable-wiki.sh ibmi2/foo

ownerrepo=$1
pushd data/${ownerrepo}.git >/dev/null
if ! gh api -X PATCH repos/${ownerrepo} -f has_wiki='false' >/dev/null 2>/dev/null; then
    echo FAILED TO DISABLE WIKI FOR {$ownerrepo}
    echo gh api -X PATCH repos/${ownerrepo} -f has_wiki='false' >>../../../fixups.sh
fi
popd >/dev/null
