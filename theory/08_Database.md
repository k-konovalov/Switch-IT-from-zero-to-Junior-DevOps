# Базы данных
1. Установка и настройка PostgreSQL 
   - ставим на голый хост базу 
   - настраиваем pg_hba файл на примем запросов из вне
   - ставим dbeaver - подключаем туда наш сервер Postgres
2. Администрирование 
   - создай базы для своего проекта и прокинь их в настройки docker своих контейнеров 
   - сделай тоже самое через psql
3. Язык запросов SQL 
   - попробуй написать SQL запрос на создание таблиц в базе, создание записей в ней и потом выборки строк из таблицы
4. Cоздание баз/таблиц
5. Бэкапирование / Восстановление 
   - dbeaver
   - через pg_dump / pg_restore