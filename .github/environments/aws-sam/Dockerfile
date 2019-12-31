FROM linuxbrew/brew

RUN brew tap aws/tap
RUN brew install awscli aws-sam-cli node
RUN npm install -g cfpack.js

WORKDIR /cardboardci