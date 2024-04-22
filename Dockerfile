FROM python:3.12-alpine AS base

# Set up environment variables
# Ensures any executable installed in the virtual environment are accesible
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

FROM base AS builder

# Set Poetry environment variables
# VIRTUALENVS_IN_PROJECT creates the .venv inside the project's root directory
# VIRTUALENVS_CREATE creates a new virtual environment if one doesn't already exist
# POETRY_CACHE_DIR sets the cache directory to later remove cached downloaded packages
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \       
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

RUN pip install poetry

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root && rm -rf "$POETRY_CACHE_DIR"

# The runtime image, used to just run the code provided its virtual environment
FROM base AS runtime

# Copy the contents of the virtual environment of the builder stage
# This ensures that the necessary dependencies are available in the runtime environment
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Copy the source code
COPY ./src /app/

WORKDIR /app/src

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
