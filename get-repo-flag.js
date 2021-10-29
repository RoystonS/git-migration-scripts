const [,,orgAndRepo, property] = process.argv;

const [org, repo] = orgAndRepo.split('/');

const proj = require("./" + org + ".json").find(x => x.nameWithOwner == orgAndRepo);
console.log(proj[property]);

