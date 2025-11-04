#import "../template.typ": *


= Welcome



#slide[





  #qa[What is the meaning of the word 'Rust' in this context?][It's the name of a kind of organism: robust 'funghi']

  #image("images/funghi.jpg", width: 50%)

  (Don't listen to your Flemish grandma, it is *not chilling*, it's "Roest" in Dutch.)




]



== Participants

#slide[



  Round of introductions:


  - What is your name?
  - What would you like to learn?
    #pause
    - Microcontrollers?
    - Web servers?
    - Robotics?


  #pause

  - What is your experience with programming?
  - What is your experience with Rust?
]


== Me

#focus-slide[
  #image("images/inbiose.jpg", height: 100%)

]

#slide[
  === Experience
  Teaching experience:
  - Mathematics tutor for 5 years (students 10-25 years old): analysis, statics, algebra, calculus, ...
  - Part-time mathematics teacher at adult school for 1 year
  - Organising internal Rust workshops at software companies (2 years)
  - Organising systems programming workshops at #link("https://sysghent.be")[SysGhent.be] (1 year)

  #pause

  Rust experience:
  - Control small-scale fermentation robot and peripherals with Rust (1 year)
  - Architect and implement remote control system for freight trains in Rust (1 year)
  - Various hobby projects and conference talk

  #pause
  Contact information:

  - Questions: #link("willemvanhulle@protonmail.com")
  - Website: #link("willemvanhulle.tech"), #link("github.com/wvhulle")

]





#slide[
  === Hobby projects
  Latest Rust hobby projects: #link("https://crates.io/crates/nu-lint")[`nu-lint`] (linter NuShell) and a `firewall-manager`

  #info[Nushell is a modern shell written in Rust.]

  Makes pipelines easier with modern syntax and types:

  ```nu
    date now                    # 1: today
    | $in + 1day                # 2: tomorrow
    | format date '%F'          # 3: Format as YYYY-MM-DD
    | $'($in) Report'           # 4: Format the directory name
    | mkdir $in                 # 5: Create the directory
  ```


  #pause

  #warning(title: [Free Nu workshop])[
    On Wed, 3rd of December, I will give a free workshop on NuShell in this location. Register at #link("https://www.meetup.com/nl-nl/sysghent/events/311799711/")[SysGent meetup page].
  ]
]

== Misconceptions about Rust


#slide[
  #qa[It's too difficult.][
    No, it is only hard in the first 1 month. \ After that, you will experience relief. You will be able to sleep at night (no more segfaults!).
  ]

  #qa[It's not used in industry.][
    No, big companies are actually using it: Google, Amazon, Microsoft.
    \ Near Ghent: Robovision, Barco, OTIV, ... . In coming years more and more: Keysight, Infrabel, ...
  ]

  #qa[Rust is only for systems programming.][
    No, you can build:
    - Web applications (backend and frontend)
    - Command-line tools
    - Data science and machine learning
  ]

]

== Ultimate goal

#slide[

  By the end of this course, you should be able to *publish your own code* to the Rust package registry #link("crates.io").


  #warning[
    *Start thinking now* what you would like to build and let me know before next session!
  ]
]

#focus-slide[
  #image("images/cratesio.png")
]



== Learning material



#slide[



  Theory:
  - These *slides contain extra diagrams*:
    - #link("https://github.com/wvhulle/rust-course-ghent")
    - written in Typst (a Rust based typesetting language like LaTeX)
  - Book: "Programming Rust" by Jim Blandy, any edition ($~ 35 euro$, ask me for e-book)

  #pause

  Exercises:
  - Exercise from Google's Rust course
  - More exercises #link("https://exercism.org/tracks/rust")
  - Lots of official documentation #link("https://doc.rust-lang.org/std/index.html")

  Our aim in this course: *$>50%$ exercises!*


]


#focus-slide[
  #image("images/docrs.png")
]

== Setup for exercises


#slide[
  You don't have to install Rust for this first lecture:

  - Solve during lectures in playground https://play.rust-lang.org
  - Code samples have a "playground link" at the bottom right


  #pause

  Do you prefer to do exercises locally?

  - Find copies of exercises in the `session-N/examples/` folders
  - Run them with `cargo run --example s1e1-fibonacci` (from root or session folder).

  #pause

  Still need harder challenges:

  - Find additional exercises on #link("https://exercism.org/tracks/rust/exercises").
  - Work on your own project!


]

#focus-slide[
  #image("images/exercism.png", width: 100%)
]


== Course contents

#slide[

  Each session is 2 hours long. Longer break in the middle. Half theory, half exercises.

  1. Introduction, *rust basics, patterns, methods, traits, generics* (+ homework)
  2. Functional programming & standard library
  3. Ownership & borrowing fundamentals
  4. Smart pointers & memory management
  5. Iterators, modules & testing
  6. Error handling & concurrency
  7. Asynchronous programming
]


== Rust today


#slide[



  Part 1: Rust fundamentals:

  - Types and values
  - Control flow basics
  - Tuples and arrays
  - References
  - User-defined types

  #pause

  Part 2: Important Rust concepts:

  - Pattern matching
  - Methods
  - Traits (maybe at home)
  - Generics (maybe at home)


]
