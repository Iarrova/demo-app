# The builder image, used to build the virtual environment
FROM python:3.12-bullseye AS builder

RUN pip install poetry

# Set Poetry environment variables
# VIRTUALENVS_IN_PROJECT creates the .venv inside the project's root directory
# VIRTUALENVS_CREATE creates a new virtual environment if one doesn't already exist
# POETRY_CACHE_DIR sets the cache directory to later remove cached downloaded packages
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \       
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /code

COPY pyproject.toml ./
RUN touch README.md

RUN poetry install --without dev --no-root && rm -rf "$POETRY_CACHE_DIR"

# The runtime image, used to just run the code provided its virtual environment
FROM python:3.12-slim-bullseye AS runtime

# Set up environment variables
# Ensures any executable installed in the virtual environment are accesible
ENV VIRTUAL_ENV=/code/.venv \
    PATH="/code/.venv/bin:$PATH"

# Copy the contents of the virtual environment of the builder stage
# This ensures that the necessary dependencies are available in the runtime environment
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Copy the source code
COPY ./src /code/src

# Run the application
CMD ["uvicorn", "code.main:app", "--host", "0.0.0.0", "--port", "8000"]