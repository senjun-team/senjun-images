# Haskell image

- `config` - конфигурационный файл, описывает репозиторий и глобальные настройки cabal. 
- `user-code.cabal` - главный файл проекта, менять не надо. 
- `user_code/` - каталог шаблон для запуска тестов задачи пользователя. 
- `user_code/src/UserCode.hs` - код задачи пользователя. 
- `user_code/test/Main.hs` - код теста. Как правило, это файл `wrapper_test` из текста курса. 


# Запуск для задачи
Кладем код пользователя в `user_code/src/UserCode.hs`.
Подкладываем тест в `user_code/test/Main.hs`.
Делаем `cabal test`.
