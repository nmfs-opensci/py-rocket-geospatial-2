#!/usr/bin/env Rscript

# Usage:
#   Rscript scripts/extract_pins_r.R /usr/local/lib/R/site-library > packages-r-pinned.R
#
# Notes:
# - Uses the image's default CRAN repo: getOption("repos")[1]
# - Avoids \s escapes by using [[:space:]]*

args <- commandArgs(trailingOnly = TRUE)
lib_path <- if (length(args) >= 1) args[[1]] else .libPaths()[1]

pkgs <- installed.packages(lib.loc = lib_path)
repo <- getOption("repos")[1]

cat("#! /usr/bin/env Rscript\n")
cat("# Generated pinned installs\n")
cat(sprintf('repo <- "%s"\n\n', repo))

for (i in seq_len(nrow(pkgs))) {
  pkg <- pkgs[i, "Package"]
  ver <- pkgs[i, "Version"]

  priority <- pkgs[i, "Priority"]
  if (!is.na(priority) && priority %in% c("base", "recommended")) next

  desc <- file.path(lib_path, pkg, "DESCRIPTION")
  if (file.exists(desc)) {
    lines <- readLines(desc, warn = FALSE)
    rt <- grep("^RemoteType:", lines, value = TRUE)

    if (length(rt) > 0 && grepl("github", rt, ignore.case = TRUE)) {
      ru <- grep("^RemoteUsername:", lines, value = TRUE)
      rr <- grep("^RemoteRepo:", lines, value = TRUE)
      rs <- grep("^RemoteSha:", lines, value = TRUE)

      if (length(ru) > 0 && length(rr) > 0) {
        user <- sub("^RemoteUsername:[[:space:]]*", "", ru)
        repo_name <- sub("^RemoteRepo:[[:space:]]*", "", rr)

        if (length(rs) > 0) {
          sha <- sub("^RemoteSha:[[:space:]]*", "", rs)
          sha7 <- substr(sha, 1, 7)
          cat(sprintf('remotes::install_github("%s/%s@%s", upgrade = "never") # %s\n',
                      user, repo_name, sha7, ver))
        } else {
          cat(sprintf('remotes::install_github("%s/%s", upgrade = "never") # %s\n',
                      user, repo_name, ver))
        }
        next
      }
    }
  }

  cat(sprintf('remotes::install_version("%s", version = "%s", repos = repo, upgrade = "never")\n',
              pkg, ver))
}
