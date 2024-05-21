ARG NODE_VERSION=20


FROM node:$NODE_VERSION-alpine AS base


FROM base as deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package*.json .npmrc ./
RUN npm ci


FROM base as builder

WORKDIR /app

COPY --from=deps /app/ ./
COPY next.config.mjs tsconfig.json ./
COPY /prisma ./prisma
COPY /public ./public
COPY /src ./src

ENV NEXT_ESLINT_DISABLED 1
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build


FROM base as app

WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

RUN mkdir .next
RUN chown nextjs:nodejs .next

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
RUN npm --global --save-exact install "prisma@$(node -p "require('./node_modules/@prisma/client/package.json').version")"

COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/prisma ./prisma
COPY --chown=nextjs:nodejs entrypoint.sh ./

USER nextjs

ENV HOSTNAME '0.0.0.0'
ENV PORT 3000

EXPOSE 3000

ENTRYPOINT [ "./entrypoint.sh" ]
