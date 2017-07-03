# Wires
[![travis-ci](https://travis-ci.org/facile-it/Wires.svg?branch=master)](https://travis-ci.org/facile-it/Wires)
[![codecov](https://codecov.io/gh/facile-it/Wires/branch/master/graph/badge.svg)](https://codecov.io/gh/facile-it/Wires)

Functional Reactive abstractions for Swift.

---

## Yet Another Functional Reactive Library?

Functional Reactive Programming (FRP) is big. So big that it shouldn't be tied to a specific library or a specific set of abtractions with particular names, like *Observable*, *Signal* or *Binding*.

What really matters are the first principles, and **Wires** is a library that tries to clearly define those principles, and build useful stuff from them.

I actually started building FRP libraries to educate myself about the topic, but I reached a decent enough level of confidence to be able to use them in production, and `Wires` is an attempt to define a proper `1.0.0`.

---

## What's inside

In `Basics.swift` are defined the 4 basic ingredients: the `Signal` type, along with 3 protocols, `Producer`, `Transformer` and `Consumer`. Because everything is defined with protocols, you could make any type you want conform to a particular interface, and the define specific semantics for that type (for example, a `UIViewController` could be a `Consumer` of a `ViewModel`).

In `Connections.swift` is defined the `Wire` class: it allows to *connect* a `Producer` and a `Consumer` in a type-safe way, and handles the memory ownership.

In `Producers.swift`, `Transformers.swift` and `Consumers.swift` are defined many useful concrete types to start with. *Transformers* are usually referred as *Operators* (like `map`, `flatMap`, `debounce` et cetera).

The other files contain the necessary type erasers, and some utilities.
