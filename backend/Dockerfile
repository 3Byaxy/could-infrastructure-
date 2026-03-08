# Use official Python slim image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install dependencies first (leverages Docker layer cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY app.py .

# Expose API port
EXPOSE 5000

# Run with Gunicorn (production WSGI server)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "4", "app:app"]
