# Elm Continue

Library for manipulating and composing continuations in Elm.

**Usage of `Continuation` would be probably discouraged by broader elm community.
Use this package as learning material or use it wisely**

This package contains lightweight implementation of abstractions to work with continuations
which are commonly described as Continuation as Functor (`map`), Applicative (`andMap`) and Monad (`andThen`).

One of the practical usages one can see is to use it as a decoupling mechanism.
You might be interested in [G. Gonzalez's blog post](http://www.haskellforall.com/2012/12/the-continuation-monad.html) on this topic.

*Please note that this implementation is fairly limited as we can't express Monad Transformers in elm.*

See [examples](examples)
