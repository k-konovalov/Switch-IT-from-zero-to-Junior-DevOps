# 01.03. Network - SSH

## SSH connection to server
Для соединения по ssh есть bash команда: `ssh`.
- `ssh {username}@{ip_adress}`
    - username: пользователь (root, admin и т.п)
    - ip_adress: ip-адрес назначения (10.0.0.0)
      Если нужно использовать порт отличный от стандартного (TCP: 22), то используется:
    - `ssh {username}@{ip_adress} -p 2022`
        - -p 2022: смена порта

## Troubleshooting
- Warning remote host identification has changed!
  - Почему-то сменилась хеш сумма сервера
  - Удалить ~/.ssh/known_hosts
