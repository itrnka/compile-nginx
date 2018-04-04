# compile-nginx

Prepare script (make files executable):
```bash
find . -type f -iname "*.sh" -exec chmod +x {} \;
```

Display help:
```bash
sudo ./install.sh --help
```

Run script:
```bash
sudo ./install.sh --user my-nginx-user --group my-web-group --nginx-header-value my-server-name
```

Run script with default values:
```bash
sudo ./install.sh --default
```
