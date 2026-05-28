# Fix Master Key

The master key file has the wrong format. Run these commands to fix it:

```bash
cd /Users/patricko/projects/gumshoeapi

# Remove the old master key and credentials file
rm config/master.key config/credentials.yml.enc

# Generate a new master key (64 hex characters, no newline)
openssl rand -hex 32 | tr -d '\n' > config/master.key

# Verify it's exactly 64 characters
wc -c config/master.key
# Should show 64 (or 65 if there's a newline, which is fine)

# Now create the credentials file
EDITOR="nano" bin/rails credentials:edit
```

When the editor opens, paste this:

```yaml
gumshoe:
  api_key: your_gumshoe_api_key
```

Save (Ctrl+O, Enter) and exit (Ctrl+X).
