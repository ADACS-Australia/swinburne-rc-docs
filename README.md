# Swinburne Research Cloud Quickstart Guide
This repository contains the source files (markdown) for the quickstart guide [https://dliptai.github.io/Swinburne-RC-Quickstart-Guide]().

The HTML for the webpage exists on the `gh-pages` branch of this repository, and is generated with the `mkdocs` tool.

## Instructions
Pull the master branch of this repository.

### Modifications
Webpage configuration is contained in `mkdocs.yml`.
Markdown for each page is in the `docs` directory.

### Preivew (optional)
You can preview the webpage locally by executing the following command in the base directory of the repository
```
mkdocs serve
```
The ouput will tell you where you can then view the webpage (typically port 8000 of the localhost).

### Deploy
To build and deploy the html, run
```
mkdocs gh-deploy
```
This will push the html to gh-pages branch.

### Build (optional)
To view the html locally, you can switch to the gh-pages branch, or you can build it in the main branch via
```
mkdocs build
```

## Notes
- [https://www.mkdocs.org/]()
- You can install MkDocs with `pip` or `conda` -- it requires a python installtion.
- MkDocs uses python-markdown by default.
- There are no extra dependencies.
  - We use the **ReadTheDocs** theme, which comes built-in with MkDocs.
  - The markdown extensions `admonition` and `attr_list` are included in python-markdown.

