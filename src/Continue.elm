module Continue exposing (Continue(..), andMap, andThen, exec, map, return, run)

{-| Abstraction for working with continuations.


# Type

@docs Continue, return


# Run continuation

@docs run, exec


# Compositions

@docs map, andMap, andThen

-}


{-| Continuation type
-}
type Continue r a
    = Cont ((a -> r) -> r)


{-| construct continuation from value

    return 42
      |> exec
    --> 42

-}
return : a -> Continue r a
return a =
    Cont <| \k -> k a


{-| Run function within continuation

    return "foo"
      |> run (\h -> h :: [ "bar" ])
    --> [ "foo", "bar" ]

This will inject `timesTwo` as continuation to
`squareAndAdd`. Final calculation should then be:
`n ^ 2 + n * 2` where `n` is argument passed to `squereAndAdd`.

    squareAndAdd : Int -> Continue Int Int
    squareAndAdd a =
        Cont <| \k -> a ^ 2 + k a

    times2 : Int -> Int
    times2 a =
        2 * a

    run times2 (squareAndAdd 3)
    --> 15

    run times2 (squareAndAdd 4)
    --> 24

-}
run : (a -> r) -> Continue r a -> r
run f (Cont c) =
    c f


{-| Run with identity function.

**This is useful only in case of very simple scenarios.**

    return ()
      |> exec
    --> ()

-}
exec : Continue r r -> r
exec =
    run identity


{-| Map value within continuation

    return 5
      |> map (\a -> a ^ 2)
      |> exec
    --> 25

-}
map : (a -> b) -> Continue r a -> Continue r b
map f (Cont c) =
    Cont <| \k -> c (k << f)


{-| Apply values to function within continuation

    return (\a b -> a / b)
      |> andMap (return 5)
      |> andMap (return 2)
      |> exec
    --> 2.5

-}
andMap : Continue r a -> Continue r (a -> b) -> Continue r b
andMap (Cont c) (Cont f) =
    Cont <| \k -> f (\g -> c (\a -> k (g a)))


{-| Chain continuations

    return 3
      |> andThen (\a -> return <| a * 2)
      |> exec
    --> 6

-}
andThen : (a -> Continue r b) -> Continue r a -> Continue r b
andThen f (Cont c) =
    Cont <| \k -> c (\a -> run k (f a))
