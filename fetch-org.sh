# Fetches/updates an entire Git organisation

org=$1

# Collect repo statuses
gh repo list ${org} --limit 50000 --json homepageUrl,id,isArchived,isPrivate,labels,mergeCommitAllowed,nameWithOwner,pullRequests,description,hasWikiEnabled,hasIssuesEnabled >"data/${org}.json"
# Tidy the JSON
npx prettier --write "data/${org}.json"

# Fetch/update each repo
for ownerAndRepo in $(gh repo list ${org} --limit 50000 | sed 's/\t.*//'); do
  repo_description=$(node get-repo-flag.js ${ownerAndRepo} description)

  case ${repo_description} in
  "NOT READY FOR COMMITS"*)
    # Git repo being migrated from RTC but not yet complete.
    echo Migration of ${ownerAndRepo} not yet completed from RTC. Skipping.

    if [ -d "data/${ownerAndRepo}.git" ]; then
      # We've already fetched it (or tried to).  Mark it as NOTREADY
      mv "data/${ownerAndRepo}.git" "data/${ownerAndRepo}.git.NOTREADY"
    fi
    ;;
  *)
    if [ -d "data/${ownerAndRepo}.git.NOTREADY" ]; then
      # Previously NOT READY but now ready, and we have a prior clone
      mv "data/${ownerAndRepo}.git.NOTREADY" "data/${ownerAndRepo}.git"
    fi

    # Fetch/update
    . fetch-one-repo.sh ${ownerAndRepo}
    ;;
  esac
done
