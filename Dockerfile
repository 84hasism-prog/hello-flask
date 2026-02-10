FROM python:3.11-slim

WORKDIR /app

# Installera nödvändiga systembibliotek
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Kopiera och installera beroenden
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kopiera resten av koden
COPY . .

# Starta med Gunicorn (standard för Google Cloud Run)
CMD ["gunicorn", "--bind", ":8080", "--workers", "1", "--threads", "8", "app:app"]