# ZigDash Chat (milestone 1). No secrets in the image: the bot token, the
# Anthropic key, the relay password, the keys file and the service key are
# mounted from the host at run time (deploy/docker-compose.yml).
FROM node:24-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev --no-audit --no-fund
COPY agent.mjs cli.mjs keystore.mjs link.mjs metrics.mjs replay-test.mjs service.mjs telegram.mjs wire.mjs ./
USER node
CMD ["node", "service.mjs"]
