FROM python:3.12-slim

# Install dependencies
RUN pip install --no-cache-dir flask==2.3.3 gunicorn==21.2.0 prometheus-flask-exporter==0.23.0

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application code
COPY app.py .

# Switch to non-root user
USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
