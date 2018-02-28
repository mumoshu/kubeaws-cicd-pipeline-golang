const { events, Job, Group} = require("brigadier")

function notify(e, project) {
    console.log(e.payload)
    var m = "Cluster updated"

    if (project.secrets.SLACK_WEBHOOK) {
        var slack = new Job("slack-notify")

        slack.image = "technosophos/slack-notify:latest"
        slack.env = {
            SLACK_WEBHOOK: project.secrets.slackWebhook,
            SLACK_USERNAME: project.secrets.slackUsername,
            SLACK_TITLE: "Deployment to ${e.payload.environment}",
            SLACK_MESSAGE: m + " <https://" + project.repo.name + ">",
            SLACK_COLOR: "#00ff00"
        }

        slack.tasks = ["/slack-notify"]
        slack.run()
    } else {
        console.log(m)
    }
}

function deploy(e, project) {
    var env = e.payload.environment
    var myenv = project.secrets.env
    if (myenv != env) {
	console.log("skipping deployment to ${envenv}: this pipeline will deploy only to ${myenv}");
        return
    }
    var image = project.secrets.image
    var command = project.secrets.command
    var deploy = new Job("deploy", image)

    // Set up all the namespaces with network policies, RBAC policies, and so on.
    deploy.tasks = [
        command
    ];

    // TODO create the service account "cluster-brigade"
    deploy.serviceAccount = project.secrets.serviceAccount

    deploy.run().then(res => {
        notify(e, project)
    })
}

// Trigger this via:
// - For the first time: `brig run theproject --event deployment -f pipelines/cluster/brigade.js --namespace cluster-brigade`
// - Via GitHub webhook events
events.on("deployment", deploy)
