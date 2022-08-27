const { Octokit } = require("@octokit/rest");

if (process.argv.length != 5) {
    process.exit (1)
}
const owner = process.argv[2]
const repo = process.argv[3]
const pull_number = process.argv[4]

const octokit = new Octokit({
    auth: process.env.GITHUB_AUTH_TOKEN,
})

;(async () => {
    const pull_request = await octokit.rest.pulls.get({
        owner,
        repo,
        pull_number,
    })
    if (pull_request.status !== 200) {
        process.exit (pull_request.status)
    }
    const data = pull_request.data
    // output multiple variables for bash git script
    // reference:
    //
    // remote_branch
    // user login
    // remote repo
    // commit hash
    const output = [ data.head.ref, data.user.login, data.head.repo.html_url, data.head.sha ]
    process.stdout.write (output.join (' '))
}) ()
