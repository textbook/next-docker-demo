ARG NODE_VERSION=jod

FROM node:${NODE_VERSION}-alpine AS base


FROM base AS builder

WORKDIR /app

COPY .npmrc package*.json ./
RUN npm --no-fund --no-update-notifier ci

COPY prisma/ ./prisma
COPY public/ ./public
COPY src/ ./src
COPY next.config.mjs ./
RUN NEXT_TELEMETRY_DISABLED=1 npm run build


FROM base AS app

RUN apk add --no-cache tini

WORKDIR /app

COPY --from=builder --chown=node /app/.next/standalone ./
COPY --from=builder --chown=node /app/.next/static ./.next/static
COPY --from=builder --chown=node /app/prisma ./prisma
COPY --from=builder --chown=node /app/public ./public

RUN npm install --global --save-exact "prisma@$(node --print 'require("./node_modules/@prisma/client/package.json").version')"

COPY start.sh /usr/local/bin

ENV CHECKPOINT_DISABLE=1
ENV DISABLE_PRISMA_TELEMETRY=true
ENV HOSTNAME=0.0.0.0
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

USER node

ENTRYPOINT [ "start.sh" ]
