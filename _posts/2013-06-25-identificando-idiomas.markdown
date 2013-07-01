---
layout: post
title:  Identificando Idiomas - Um Classificador Bayesiano em Ação
date:   2013-06-25 21:12:39
authors:
  - name: Ígor Bonadio
    anchor: igor
categories: estatistica
javascripts: ["http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML", "/js/Chart.min.js"]
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}
  });
</script>

É incrível como algumas ideias são simples. Mais incrível ainda é como algumas ideias simples são realmente úteis.

Nessa categoria podemos encaixar a teoria de decisão bayesiana, que em português se traduz em algo como: Escolha sempre a melhor opção. Simples, não?

Neste post irei apresentar uma abordagem de como se construir um classificador de idiomas (português e inglês, por exemplo) baseado na teoria de decisão bayesiana.

<!-- break -->

## Regra de Decisão Bayesiana

Podemos considerar o texto a ser analisado como uma sequência de caracteres. Mais especificamente podemos considerar apenas as letras que o compõem. Seja, então, um texto $X$ contendo $N$ letras definido como:

$$X = (x_1, x_2, ..., x_N)$$

onde $x_i$ é uma letra do alfabeto.

Podemos calcular a probabilidade de uma letra aparecer em um dado texto através de uma simples contagem:

$$p(c) = \frac{count_X(c)}{N}$$

onde $count_X(c)$ é o número de vezes que a letra $c$ aparece no texto $X$.

Abaixo temos estimativas das distribuições para as línguas inglesa, $p(c \mid idioma=en)$ em laranja, e portuguesa, $p(c \mid idioma=pt)$ em roxo, calculadas a partir de dois artigos da [Wikipedia][wikipedia] ([1][en], [2][pt]):

<div>
  <canvas id="langBar" height="250" width="600"></canvas>
  <script>
    var barChartData = {
      labels : ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"],
      datasets : [
        {
          fillColor : "rgba(125,79,109,0.5)",
          strokeColor : "rgba(125,79,109,1)",
          data : [0.14827586206896548, 0.009800362976406539, 0.0382940108892922, 0.05328493647912885, 
                  0.10885662431941925, 0.013829401088929225, 0.010925589836660615, 0.010381125226860254, 
                  0.06261343012704174, 0.0013430127041742282, 0.0018874773139745916, 0.03237749546279492,
                  0.03981851179673321, 0.05441016333938295, 0.10326678765880215, 0.027441016333938296, 
                  0.006569872958257716, 0.07607985480943737, 0.08820326678765882, 0.05114337568058078, 
                  0.0376043557168784, 0.014047186932849369, 3.6297640653357513E-4, 0.0028675136116152458, 
                  4.718693284936478E-4, 0.005843920145190564]
        },
        {
          fillColor : "rgba(217,112,65,0.5)",
          strokeColor : "rgba(217,112,65,1)",
          data : [0.08744125040988085, 0.013371224541844284, 0.031260247021532406, 0.04284621270084163, 
                  0.12427587714504316, 0.02615950741428936, 0.01705104382992677, 0.04914926950122053, 
                  0.06718402739825846, 7.651109410864577E-4, 0.006048019820016761, 0.045141545524101, 
                  0.02397347615404233, 0.07439793055707364, 0.07388785659634935, 0.02084016468102161, 
                  6.922432324115572E-4, 0.06747549823295806, 0.05997012423944328, 0.09290632856049842, 
                  0.027398258461762668, 0.012023171931358613, 0.01570299121944111, 0.0014573541734980147, 
                  0.015083615695704442, 0.003497650016395233]
        }
      ]
      
    }
  var myLine = new Chart(document.getElementById("langBar").getContext("2d")).Bar(barChartData);
  </script>
</div>

Podemos utilizar essa distribuição como base para construirmos nosso modelo probabilístico.

Um modo bastante simplificado para tentar calcular a probabilidade de um texto $X$ estar escrito em um dado idioma é assumir que cada letra é [independente e igualmente distribuída][iid]:

$$p(X \mid idioma) = p(x_1 \mid idioma)p(x_2 \mid idioma)...p(x_N \mid idioma)$$

Nosso objetivo é, então, encontrar qual idioma tem maior probabilidade de ser o correto para um dado texto. Ou seja, qual idioma que maximiza $p(idioma \mid X)$, que pode ser calculado utilizando a regra de Bayes:

$$p(idioma \mid X) = \frac{p(X \mid idioma)p(idioma)}{p(X)}$$

Como $p(X)$ é apenas um fator de normalização e não influencia na nossa busca pelo idioma que maximize $p(idioma \mid X)$, temos que o idioma ótimo pode ser calculado como:

$$idioma^\* = argmax_{idioma} p(X \mid idioma)p(idioma)$$

Essa é a nossa regra de decisão bayesiana.

Neste caso particular, podemos assumir que $p(idioma)$ tem o mesmo valor para todos os idiomas, e assim

$$idioma^\* = argmax_{idioma} p(X \mid idioma)$$

## Likely

Até agora apenas apresentei os fundamentos de um classificador bayesiano. A partir disso você pode facilmente implementar em qualquer linguagem de programação algoritmos capazes de classificar textos. Recomendo os ambientes [R][r] e [Octave][octave] que são ótimos para experimentações.

Mas aqui apresentarei uma alternativa diferente.

Sempre que tento aprender uma linguagem de programação nova, gosto de criar algum projeto para de fato sentir como é programar utilizando aquela linguagem. No caso de Scala, iniciei o desenvolvimento de um framework probabilístico chamado [Likely][likely]. O objetivo era (e ainda é) implementar algoritmos apara análise de dados de modo que utilizando uma [DSL][dsl] fosse fácil especificar modelos probabilísticos. Esse projeto é open source e está disponível no nosso [Github][github].

Com Likely você pode definir um classificador bayesiano como:

{% highlight scala %}
  val classifier = BayesianClassifier(
    "portuguese" -> DiscreteIIDModel.train(trainSetPt),
    "english" -> DiscreteIIDModel.train(trainSetEn)
  )

  val lang = classifier.classify(text)
{% endhighlight %}

Para um exemplo completo de um classificador de idiomas veja o arquivo fonte [LanguageClassifier.scala][langclass].

Se você deseja executar esse exemplo em seu computador, você precisa ter o [SBT][sbt] instalado em seu sistema. 

Primeiramente clone o projeto:

{% highlight bash %}
  git clone git@github.com:stormcoders/likely.git
{% endhighlight %}

execute o sbt

{% highlight bash %}
  cd likely
  sbt
{% endhighlight %}

e rode o programa LanguageClassifier

{% highlight bash %}
  run "Acho que isso nao vai funcionar..."
  run "I think it will not work.."
{% endhighlight %}


## Conclusão

Minha exposição da teoria dos classificadores bayesianos foi bem superficial e se você quiser saber mais sobre isso recomendo o livro [Patter Classification, de Duda, Hart e Stork][duda]. O livro não é apenas sobre classificadores bayesianos e traz muita informação sobre vários modelos probabilísticos utilizados em reconhecimento de padrões.

Vale ressaltar também, que essa abordagem é bem simples e não tem grande desempenho. Existem outros modelos e abordagens possíveis, como considerar a ordem das letras ou utilizar palavras inteiras. 

O objetivo deste post era apenas mostrar como a utilização de um técnica bem simples (de entender e de implementar) pode nos trazer resultados interessantes.

Por fim gostaria de dizer que continuarei desenvolvendo o Likely e caso você queira contribuir, por favor faça um fork do [projeto][likely].

[wikipedia]:http://www.wikipedia.org/
[en]:http://en.wikipedia.org/wiki/Battle_of_Austerlitz
[pt]:http://pt.wikipedia.org/wiki/Batalha_de_Austerlitz
[iid]:http://en.wikipedia.org/wiki/Independent_and_identically_distributed_random_variables
[r]:http://www.r-project.org/
[octave]:http://www.gnu.org/software/octave/
[dsl]:http://en.wikipedia.org/wiki/Domain-specific_language
[likely]:https://github.com/stormcoders/likely
[github]:https://github.com/stormcoders
[langclass]:https://github.com/stormcoders/likely/blob/master/src/main/scala/br/com/stormcoders/likely/examples/language_classifier/LanguageClassifier.scala
[sbt]:http://www.scala-sbt.org/
[duda]:http://www.amazon.com/Pattern-Classification-Pt-1-Richard-Duda/dp/0471056693/ref=sr_1_1?ie=UTF8&qid=1372266513&sr=8-1&keywords=pattern+classification