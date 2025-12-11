// Centralized external package imports
// This file consolidates all external dependencies in one place to avoid
// scattered imports across multiple files. When updating package versions or sources,
// only update them here.

// Presentation framework
#import "@local/touying:0.6.1": (
  at, between, components, config-colors, config-common, config-info,
  config-methods, config-page, config-store, meanwhile, only, step,
  touying-reducer, touying-slide, touying-slide-wrapper, touying-slides,
  uncover, until, utils,
)

// Code syntax highlighting and formatting
#import "@preview/codly:1.3.0": (
  codly, codly-disable, codly-init, codly-reset, no-codly,
)

// QR code generation
#import "@preview/tiaoma:0.3.0": *

// Theorem support
#import "@preview/theorion:0.3.2": show-theorion, theorem-counter

// Diagram and visualization packages
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, hide, node, shapes
#import "@preview/cetz:0.4.2": canvas, draw

// Re-export commonly used items for convenience
#let pause = {
  import "@local/touying:0.6.1": pause
  pause
}

// Re-export fletcher module for direct access
#let fletcher = fletcher

// Touying bindings for CeTZ and Fletcher diagrams
#let cetz-canvas = touying-reducer.with(
  reduce: canvas,
  cover: draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: diagram,
  cover: hide.with(bounds: true),
)
