# Architecture decision records

These are records of major technical decisions we made while building the
production TDR system, so that we remember _why_ we made those decisions and to
make it easier to reassess or change those decisions in the future.

This folder just contains decisions that made it into the Beta/Live system. See
the [technology-considerations folder](../technology-considerations) for notes
on prototypes and technical spikes.

There's a good overview of ADRs here: https://github.com/joelparkerhenderson/architecture_decision_record

We should add an ADR whenever we make a decision about the system that:

- Has a large impact on non-functional requirements like maintainability,
  performance or security
- Will be hard to change later
- Has several alternatives (though we should document a decision even if the
  answer seems obvious - it might not look that way to someone looking back on
  the decision later)

Examples of decisions that are worth documenting: choosing a database or
JavaScript framework, or a plan for how different applications will communicate
using an asynchronous message queue.

Examples of other team's ADRs:

- https://github.com/alphagov/govuk-aws/tree/master/doc/architecture/decisions
- https://github.com/alphagov/search-api/tree/master/doc/arch
- https://github.com/arachne-framework/architecture

## Structure

Each ADR should have:

- A date
- Background context
- The decision, and why it was chosen

You might choose to add other sections, such as:

- Assumptions
- Constraints
- Evaluation criteria
- Options considered
- Implications
- Related decisions

The decision itself should be considered immutable when it's merged. If we
change our approach, we should add a new ADR explaining the change, leaving the
original as a reference and marking it as deprecating.

If the decision has significant or unexpected consequences, we can also add a
new section explaining what happened. This might help other developers who are
making similar decisions in future.
