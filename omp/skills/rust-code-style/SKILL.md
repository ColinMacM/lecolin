---
name: rust-code-style
description: Rust doc comments, spacing and file layout when writing or editing .rs files.
---

# Rust code style

## Comments and rustdoc

- Add a comment only when it helps a reader understand something the name, signature and code do not already show. No comment is the default for obvious code; do not document every function, type, field or test.
- Keep public API rustdoc where it explains behavior a caller needs: units, frames, valid ranges, error conditions, side effects, ownership, ordering, uncertainty or device quirks. Preserve useful contracts and required `# Safety` documentation.
- Simple getters, constructors, standard trait implementations and forwarding methods usually need no comment. Do not repeat the trait's contract on its implementation.
- Test names and assertions should explain ordinary cases. Comment only a non-obvious fixture assumption, race, regression or reason for the scenario; do not narrate the assertions or enumerate every case.
- Use plain language and the shortest useful explanation, usually one sentence or a short paragraph. Do not fill a sentence quota or add boilerplate sections. Module docs give purpose and key constraints.
- Doc comments describe only the item they are on. Do not mention other files, paths, documents, manuals, READMEs or tests; to point at related code, use a rustdoc intra-doc link to the item (``[`RobotHandle`]``), never a file name. Do not mention agents, sessions, owners, task assignments or who wrote or changed the code.
- Field comments are only for non-obvious units, frame or identity conventions, or a special `None` meaning. Inline comments explain why an operation is necessary; do not narrate mechanical steps.
- When changing code, remove redundant comments and correct stale ones, including any that name files or agents. Do not replace a removed comment with another paraphrase of the code or invent facts to justify a comment.

```rust
/// Counts frames missed between sequence numbers; restart or wrap reports zero rather than a negative gap.
```

## Types

- Give every value with a unit, frame or identity its own newtype, not a bare number or string.
- Error messages name the violated rule and show the offending values, for example "exposure 90 exceeds 83 (100 µs units) at 120 fps".

## Spacing in bodies

- One blank line separates distinct thoughts. Put one before and after a standalone `if`, `for`, `while`, `match` or `loop`, and between setup and the logic that uses it.
- No blank line between consecutive `let` bindings of one thought, inside nested loops, inside an `if / else if / else` chain, between `match` arms, or between a binding and the block that consumes it.

## File layout

- One concept per module, small enough to read in one sitting.
- Types come first. Functions follow as a ladder where each function sits below the ones it calls, with helpers at the top and entry points at the bottom.
