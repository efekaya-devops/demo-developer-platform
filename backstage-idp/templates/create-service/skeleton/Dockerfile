FROM node:22-alpine
WORKDIR /app
COPY package.json server.js ./
USER node
EXPOSE 8080
HEALTHCHECK CMD wget -qO- http://localhost:8080/healthz || exit 1
CMD ["node", "server.js"]
