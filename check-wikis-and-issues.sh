org=$1

echo Checking wikis in ${org}

rm -f fixups.sh
for ownerAndRepo in $(gh repo list ${org} --limit 500000 --json nameWithOwner,hasWikiEnabled --jq ".[] | select(.hasWikiEnabled == true) | .nameWithOwner"); do
  . fetch-one-repo.sh ${ownerAndRepo}.wiki >/dev/null 2>/dev/null
  if [[ -d "data/${ownerAndRepo}.wiki.git" ]]; then
    echo ${ownerAndRepo} has Wiki enabled and has pages. Needs attention.
  else
    echo ${ownerAndRepo} has Wiki enabled but no pages. Disabling.
    . disable-wiki.sh ${ownerAndRepo}
  fi
done

echo Checking issues in ${org}

for ownerAndRepo in $(gh repo list ${org} --limit 500000 --json nameWithOwner,hasIssuesEnabled --jq ".[] | select(.hasIssuesEnabled == true) | .nameWithOwner"); do
  pushd "data/${ownerAndRepo}.git" >/dev/null
  actually_has_issues=$(gh issue list --state all --limit 1 | wc -l)
  popd >/dev/null

  if [[ "${actually_has_issues}" == "1" ]]; then
    echo ${ownerAndRepo} has issues enabled and has used issues. Needs attention.
  else
    echo ${ownerAndRepo} has issues enabled but no actual issues. Disabling.
    . disable-issues.sh "${ownerAndRepo}"
  fi
done
