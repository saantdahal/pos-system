
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/home/django/.local/bin:$PATH"

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        curl \
        netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements from correct path
COPY backend/bhansaGhar_backend/requirements.txt .

RUN pip install --upgrade pip \
    && pip install -r requirements.txt --no-cache-dir

# Copy backend source code only
COPY backend/bhansaGhar_backend/ .

RUN useradd -m -u 1000 django && chown -R django:django /app
USER django

EXPOSE 8001

CMD ["gunicorn", "--bind", "0.0.0.0:8001", "bhansaGhar_backend.wsgi:application"]
