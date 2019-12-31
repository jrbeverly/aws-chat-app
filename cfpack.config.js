module.exports = {
	entry: "infrastructure", // folder with templates
	output: ".out/cloudformation.json", // resulting template file
	verbose: true, // whether or not to display additional details
	silent: false, // whether or not to prevent output from being displayed in stdout
	// unused: we use sam for deploying.
	stack: {
		name: "websocket-chat-app",
		region: "us-east-1",
		params: {},
	},
};
