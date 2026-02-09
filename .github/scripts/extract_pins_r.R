#!/usr/bin/env Rscript

# Usage:
#   Rscript .github/scripts/extract_pins_r.R [lib_path]
#
# Output:
#   Writes pinned install commands to stdout (so the caller can redirect to a file).

args <- commandArgs(trailingOnly = TRUE)
lib_path <- if (length(args) >= 1) args[[1]] else .libPaths()[1]

if (!dir.exists(lib_path)) {
  stop(sprintf("Library path does not exist: %s", lib_path), call. = FALSE)
}

pkgs <- installed.packages(lib.loc = lib_path)
repo <- getOption("repos")[1]

cat("#!/usr/bin/env Rscript\n")
cat("# Pinned R package installs\n")
cat("# Generated automatically from container image\n\n")
cat(sprintf('repo <- "%s"\n\n', repo))

for (i in seq_len(nrow(pkgs))) {
  pkg <- pkgs[i, "Package"]
  ver <- pkgs[i, "Version"]

  priority <- pkgs[i, "Priority"]
  if (!is.na(priority) && priority %in% c("base", "recommended")) next

  desc_path <- file.path(lib_path, pkg, "DESCRIPTION")

  # GitHub installs
  if (file.exists(desc_path)) {
    lines <- readLines(desc_path, warn = FALSE)
    remote_type <- grep("^RemoteType:", lines, value = TRUE)

    if (length(remote_type) > 0 && grepl("github", remote_type, ignore.case = TRUE)) {
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

  # CRAN pinned installs
  cat(sprintf('remotes::install_version("%s", version = "%s", repos = repo, upgrade = "never")\n',
              pkg, ver))
}
