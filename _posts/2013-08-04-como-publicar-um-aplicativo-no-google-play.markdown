---
layout: post
title:  "Como publicar um aplicativo no Google Play"
date:   2013-09-04 22:34:39
authors:
  - name: Marco Lopes
    anchor: marco
categories: google play
---


Publicar um aplicativo pela primeira vez no Google Play pode não ser uma tarefa muito amistosa, mas com certeza não é o fim do mundo!

Vou passar brevemente por todas as etapas e apontar onde tive problemas. Para mais informações acesse os links para ler o material oficial. É muito importante a leitura do material oficial para evitar algumas bobeiras como a que cometemos e que será citada a seguir.

<!-- break -->

A primeira coisa a se fazer é criar a sua conta de administrador. É cobrada uma taxa de US$ 25,00. Esta taxa é cobrada para desencorajar a criação de aplicativos com spam, por exemplo. Você pode se registrar [aqui][contaAdm].


Depois disso e do seu aplicativo devidamente programado e testado, podemos começar o processo de publicação! =D

A primeira coisa a se fazer é compilar o seu aplicativo para produção. Para isso devemos alterar o AndroidManifest.
O atributo 'android:debuggable' deve ser setado para 'false'. É no AndroidManifest que você irá dar nome pro seu apk, pro seu package, versão... etc. Então é importante a leitura da sua [documentação][AndroidManifest]. Além disso todos os diretórios devem ser limpos e todos os ícones alterados. Para ler sobre o processo completo acesse o [material oficial][preparing]. 

Como estávamos utilizando a plataforma [Apache Cordova][cordova], nos enrolamos um pouco para compilar para produção, mas é muito simples. Basta executar: 

{% highlight bash %}
  ./diretorioApp/cordova/build --release
{% endhighlight %}

E é aqui que vem o passo mais importante: a criação da chave!!!

Por que é tão importante? Por que esta chave será utilizada por toda a vida de seu aplicativo! Futuras versões devem ser assinadas com a mesma chave para serem aceitas. Por este motivo guarde este arquivo com muito carinho na sua home. Melhor não... guarde em algum lugar seguro e organizado! E sim... nós já sobrescrevemos a chave de um app e perdemos o direito de atualizá-lo. 

Caso ainda não esteja convencido, recomendo que leia esta [discussão][discussao].

Dito isto, o comando apara a criação da chave é este:

{% highlight bash %}
  $ keytool -genkey -v -keystore my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
{% endhighlight %}

Lembre-se de trocar my-release-key e alias_name por nomes que tenham alguma relação com o seu app. Esta pode ser a etapa mais complicada deste post.

Após ter gerado sua chave e a guardado muito bem (sério, leia a [discussão][discussao]), devemos assinar o nosso apk com o comando a seguir sem esquecer de trocar my_application, my-release-key e alias_name pelos nomes que você escolheu anteriormente (ou não). 

{% highlight bash %}
  jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore my_application.apk alias_name
{% endhighlight %}

Feito isso, basta alinhar o seu arquivo:

{% highlight bash %}
  zipalign -v 4 your_project_name-unaligned.apk your_project_name.apk
{% endhighlight %}

Pronto!

Seu aplicativo está pronto para ser publicado!

Agora basta acessar o Developer Console e seguir as instruções para cadastrar o aplicativo.

É isso, pessoal! Qualquer dúvida entrem em contato pelos comentários!


[contaAdm]: https://play.google.com/apps/publish/v2/
[preparing]: http://developer.android.com/tools/publishing/preparing.html
[cordova]: http://cordova.apache.org/
[discussao]: https://groups.google.com/forum/#!topic/android-developers/pocbQfvBdoU
[AndroidManifest]: http://developer.android.com/guide/topics/manifest/manifest-intro.html