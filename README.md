# Swinburne Research Cloud Quickstart Guide
This repository contains the source files (markdown) for the quickstart guide, which can be built into html with MkDocs.

The `Dockerfile` builds an image that can run `mkdocs build` in the root of the repository.

`docker-compose.yml` describes two services, one to build the docs into html, and the other to launch an `nginx` server. The `nginx` container listens on port `9001`.

## Instructions to deploy
Execute `docker-compose up -d --build`. This builds the site and then launches the server.

If you need to rebuild the html, execute `docker-compose run mkdocs`.

## Modifications
Webpage configuration is contained in `mkdocs.yml`.
Markdown for each page is in the `docs` directory.

## Notes
- [https://www.mkdocs.org/]()
- You can install MkDocs with `pip` or `conda` -- it requires a python installtion.
- MkDocs uses python-markdown by default.
- There are no extra dependencies.
  - We use the **ReadTheDocs** theme, which comes built-in with MkDocs.
  - The markdown extensions `admonition` and `attr_list` are included in python-markdown.

