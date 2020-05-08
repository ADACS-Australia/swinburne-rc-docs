FROM python:3-slim

RUN pip install --no-cache-dir mkdocs

WORKDIR /mkdocs_build

CMD ["mkdocs", "build"]
