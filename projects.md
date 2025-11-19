# Tiny Timeseries Transformer `tts-transformer`

Proposal by: Wietse

I propose to implement a small, educational transformer library in Rust, focused
on numeric time series instead of text.

The library should:

* take sequences of real-valued vectors
* project them into a transformer's model space
* apply standard transformer blocks (self-attention, feedforward, layer norm,
  residuals)
* output predictions for the next value(s) in the sequence

As a demonstration task, we could train or at least evaluate the model on simple
synthetic sequences such as Fibonacci-like recurrences (e.g. `x[t] = x[t−1] + x[t−2]`),
checking whether the transformer can learn to predict the next term.

The goal is not performance, but a clear implementation that helps understand
how transformers process sequential numerical data.
