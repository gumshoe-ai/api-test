# Setting Up Credentials

The credentials file needs to be created using Rails' built-in command. Run this in your terminal:

```bash
EDITOR="nano" bin/rails credentials:edit
```

When the editor opens, paste this content:

```yaml
gumshoe:
  api_key: your_gumshoe_api_key
```

Then:
1. Save the file (Ctrl+O, then Enter in nano)
2. Exit the editor (Ctrl+X in nano)

Rails will automatically encrypt and save the credentials file.

After this, you can start your server:
```bash
PORT=3001 bin/rails server
```
