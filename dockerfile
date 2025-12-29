FROM node:24-alpine AS build

WORKDIR /build

COPY package*.json ./

RUN npm install

COPY . .

RUN npx prisma generate

RUN npm run build

RUN npm ci -f --only=production && npm cache clean --force

FROM node:24-alpine

WORKDIR /usr/src/app

COPY --from=build /build/node_modules ./node_modules

COPY --from=build /build/dist ./dist

COPY --from=build /build/dev.db .

ENV NODE_ENV=production

USER node

EXPOSE 3000

CMD ["node", "dist/src/main.js"]