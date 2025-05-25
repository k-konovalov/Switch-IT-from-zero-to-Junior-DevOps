# 02.05 Unix utils - Zsh

## Теория


## Задание 1: сделай себе более наглядную консоль / терминал
- Накатил скрипт установки `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- Тему оставил по умолчанию

## Задание 2: добавь в него plugins 
Добавление плагинов замедляет старт терминала.  
**Добавление плагина:**
- склонировать в `.oh-my-zsh/custom/plugins/{plugin_name}`
  - `git clone https://github.com/zsh-users/{plugin_name} ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/{plugin_name}`
- в ~/.zshrc активировать
```
plugins=(
  # other plugins...
  zsh-autosuggestions
 )
```
- перезапустить терминал или `source ~/.zshrc`

Добавил плагины:
- [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git): VCS
- [Zsh-autosuggestions Plugin](https://github.com/zsh-users/zsh-autosuggestions): автозаполнение на базе истории команд
- [Zsh-syntax-highlighting Plugin](https://github.com/zsh-users/zsh-syntax-highlighting): подсветка синтаксиса bash команд
- [You-should-use Plugin](https://github.com/MichaelAquilina/zsh-you-should-use): подсветка алиаса, если его можно использовать вместо команды
- [Zsh-bat Plugin](https://github.com/fdellwing/zsh-bat): замена cat на bat. Подсветка синтаксиса выводимых тектсовых файлов.
- [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode): vim подобная навигация в строке + редактирование команды
- [autoupdate-zsh-plugin](https://github.com/tamcore/autoupdate-oh-my-zsh-plugins): автообновление плагинов

## Ссылки
- [Oh My Zsh - a delightful open source framework for Zsh](https://ohmyz.sh/)
- [The Only 6 Zsh Plugins You Need](https://catalins.tech/zsh-plugins/)
- [Список плагинов по звездам.](https://github.com/topics/zsh-plugins)