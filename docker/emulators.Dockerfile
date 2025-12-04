FROM node:18-bullseye

# Install Java (required for Firestore emulator)
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Firebase CLI
RUN npm install -g firebase-tools

# Set working directory
WORKDIR /app

# Copy backend files
COPY backend/ /app/

# Install Cloud Functions dependencies
WORKDIR /app/functions
RUN npm install

# Back to app root
WORKDIR /app

# Expose emulator ports
# 4100: Emulator UI
# 8282: Firestore
# 9190: Auth
# 9292: Storage
# 5100: Functions
EXPOSE 4100 8282 9190 9292 5100

# Start Firebase Emulators
CMD ["firebase", "emulators:start", "--project", "kua-waiting-list-dev"]
