# This dockerfile builds an image for the backend package.
# It should be executed with the root of the repo as docker context.
#
# Before building this image, be sure to have run the following commands in the repo root:
#
# yarn install --immutable
# yarn tsc
# yarn build:backend
#
# Once the commands have been run, you can build the image using `yarn build-image`
#
# Alternatively, there is also a multi-stage Dockerfile documented here:
# https://backstage.io/docs/deployment/docker#multi-stage-build

# Node 22 (not 24): a transitive dep (old scaffolder-backend via the azure-repos
# module) needs isolated-vm 5.x, which only builds up to Node 22. Both isolated-vm
# versions in the tree compile on 22. engines allows "22 || 24".
#
# PINNED to 22.22.3: Node 22.23.0 broke node-fetch v2's gzip stream handling
# (ERR_STREAM_PREMATURE_CLOSE on every internal service-to-service catalog read —
# scaffolder parameter-schema 500s, search indexing fails). The unpinned
# `node:22-bookworm-slim` tag rolled v22.22.3 -> v22.23.0 between image v10 and
# v11. Keep this pin until node-fetch is dropped/upgraded in the bundle.
FROM node:22.22.3-bookworm-slim

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Pre-create /app owned by node. With the classic (non-BuildKit) builder used by
# `az acr build`, WORKDIR would otherwise create /app as root and the tar steps
# (run as node) would fail with "Permission denied".
RUN mkdir -p /app && chown node:node /app

# From here on we use the least-privileged `node` user to run the backend.
USER node
WORKDIR /app

# Copy files needed by Yarn
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node backstage.json ./

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV=production

# This disables node snapshot for Node 20 to work with the Scaffolder
ENV NODE_OPTIONS="--no-node-snapshot"

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
COPY --chown=node:node yarn.lock package.json packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# This will include the examples, if you don't need these simply remove this line
COPY --chown=node:node examples ./examples

# Platform self-service templates (referenced by app-config.yaml catalog locations)
COPY --chown=node:node templates ./templates

# Then copy the rest of the backend bundle, along with any other files we might want.
COPY --chown=node:node packages/backend/dist/bundle.tar.gz app-config*.yaml ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
