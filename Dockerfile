# ---- Build Stage ----
FROM node:22-alpine AS builder

# Set working directory
WORKDIR /app

# Install pnpm via corepack
RUN corepack enable pnpm

# Copy dependencies files
COPY package.json pnpm-lock.yaml* ./

# Install dependencies (frozen lockfile for reproducibility)
RUN pnpm install --frozen-lockfile

# Copy the rest of the app
COPY . .

# Build the app
RUN pnpm build


# ---- Runtime Stage ----
FROM node:22-alpine AS runner

WORKDIR /app

# Copy only the build output from builder
COPY --from=builder /app/.output ./.output

# (Optional) if you need runtime files like package.json for env vars
COPY --from=builder /app/package.json ./ 

# Expose port if needed (e.g., for Nuxt/Next.js apps)
EXPOSE 3000

# Start server
CMD ["node", ".output/server/index.mjs"]
