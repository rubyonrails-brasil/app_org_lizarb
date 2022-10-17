# Instalando sua primeira aplicacao.

Tenha certeza de ter o [rvm](https://rvm.io/rvm/install), [rbenv](https://github.com/rbenv/rbenv#installation) ou [asdf](https://asdf-vm.com/guide/getting-started.html) instalado.

A versao minima do Ruby: 3.1.2

```bash
rbenv install 3.1.2
gem install lizarb
```

Crie um projeto

```bash
liza new app_1
cd app_1
```




### Executando testes

```bash
bundle install
liza test
```




### Executando o servidor web

Acesse http://localhost:3000/

```bash
liza web

liza web h=localhost p=3000
```




### Instalacao no Heroku (enquanto da tempo)

Tenha certeza de ter o ter instalado o [CLI do Heroku](https://devcenter.heroku.com/articles/heroku-cli).

```bash
git add -A
git commit -am "primeiro commit"

heroku create

git push heroku master
heroku logs --tail
```
