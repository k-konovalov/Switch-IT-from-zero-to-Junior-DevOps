# 01.03. Network - SSH

## Определение

## SSH connection to server
Для соединения по ssh есть bash команда: `ssh`.
- `ssh root@77.37.200.118`
    - root: пользователь
    - 77.37.200.118: ip-адрес назначения
      Если нужно использовать порт отличный от стандартного (TCP: 22), то используется:
    - `ssh root@77.37.200.118 -p 2022`
        - -p 2022: смена порта

## Troubleshooting
- Warning remote host identification has changed!
  - Почему-то сменилась хеш сумма сервера
  - Удалить ~/.ssh/known_hosts
