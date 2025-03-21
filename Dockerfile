# Stage 1: Build dependencies
FROM python:3.12.3-slim AS builder

# Install build dependencies for compiling libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements file and install dependencies into the virtual environment
COPY requirements.txt .
RUN python -m venv /venv && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime environment
FROM python:3.12.3-slim

# Install runtime dependencies (only necessary for running the app)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the virtual environment from the builder stage
COPY --from=builder /venv /venv
ENV PATH=/venv/bin:$PATH

# Copy application code
COPY . .

# Run FastAPI with uvicorn
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]