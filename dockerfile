# Build Stage - Creates temporary image for dependencies
FROM python:3.9-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt
# Creates: /root/.local with Python packages

# Runtime Stage - Final lightweight image
FROM python:3.9-slim
WORKDIR /app

# Copy ONLY dependencies from builder (not source code yet)
COPY --from=builder /root/.local /root/.local
# Takes: Pre-installed Python packages from builder

# Add .local binaries to PATH
ENV PATH=/root/.local/bin:$PATH
# Makes: uvicorn and other commands available

# NOW copy application source code
COPY . .
# Takes: Your app/ directory and other files

# Security: Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser
# Why: Security best practice - don't run as root

EXPOSE 8000
# Documents: Port 8000 will be used

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/api/health || exit 1
# Why: Kubernetes/Docker can monitor app health

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]








  
