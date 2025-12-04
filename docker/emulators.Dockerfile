FROM node:18-alpine

RUN apk add --no-cache \
    openjdk11-jre \
    python3 \
    py3-pip \
    git \
    curl

RUN npm install -g firebase-tools@latest

WORKDIR /workspace

COPY backend/firebase.json .
COPY backend/.firebaserc .
COPY backend/firestore.rules .
COPY backend/storage.rules .

RUN mkdir -p /workspace/seed-data

EXPOSE 4000 8080 9099 9199 5001

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:4000 || exit 1

CMD ["firebase", "emulators:start", "--project=${GCP_PROJECT:-kua-dev}", "--import=./seed-data", "--export-on-exit"]