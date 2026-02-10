# Flask med Azure SQL-stöd
FROM python:3.11-slim

# Installera ODBC Driver 18 för Azure SQL
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg2 unixodbc \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Kopiera requirements först (Layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kopiera resten av koden
COPY . .

# Gör entrypoint-skriptet körbart
RUN chmod +x entrypoint.sh

EXPOSE 8080

# Starta via skriptet som sköter databasmigreringar
CMD ["./entrypoint.sh"]
