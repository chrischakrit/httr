oauth_signature <- function(url, method = "GET", app, token = NULL, token_secret = NULL, ...) {
  method <- toupper(method)

  url <- parse_url(url)
  base_url <- build_url(url[c("scheme", "hostname", "port", "url", "path")])

  oauth <- compact(list(
    oauth_consumer_key = app$key,
    oauth_nonce = nonce(),
    oauth_signature_method = "HMAC-SHA1",
    oauth_timestamp = as.integer(Sys.time()),
    oauth_version = "1.0",
    oauth_token = token
  ))

  other_params <- list(...)
  if (length(other_params) > 0) {
    names(other_params) <- str_c("oauth_", names(other_params))
    oauth <- c(oauth, other_params)    
  }

  # Collect params, escape, sort and concatenated into a single string
  params <- c(url$query, oauth)
  params_esc <- setNames(curlEscape(params), curlEscape(names(params)))
  params_srt <- sort_names(params_esc)
  params_str <- str_c(names(params_srt), "=", params_srt, collapse = "&")

  # Generate hmac signature
  key <- str_c(curlEscape(app$secret), "&", curlEscape(token_secret))
  base_string <- str_c(method, "&", curlEscape(base_url), "&",
   curlEscape(params_str))
  oauth$oauth_signature <- hmac_sha1(key, base_string)  
  
  sort_names(oauth)
}